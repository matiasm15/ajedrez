class ImagesPiezas
  WIDTH = 333
  SOURCE = "./media/piezas.png"

  def self.draw(pieza, color, x, y, width)
    scale = width.fdiv(WIDTH)
    images[pieza][color].draw(x, y, 0, scale, scale)
  end

  def self.images
    @@images ||= {
      Rey => {
          Blancas => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(0),
          Negras => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(6)
        },
      Dama => {
          Blancas => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(1),
          Negras => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(7)
        },
      Alfil => {
          Blancas => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(2),
          Negras => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(8)
        },
      Caballo => {
          Blancas => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(3),
          Negras => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(9)
        },
      Torre => {
          Blancas => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(4),
          Negras => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(10)
        },
      Peon => {
          Blancas => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(5),
          Negras => Image.load_tiles(SOURCE, WIDTH, WIDTH).at(11)
        }
    }
  end
end

class ScreenTablero
  def initialize(width_borde, width_casilla)
    @width_borde = width_borde
    @width_casilla = width_casilla
  end

  def casilla(mouse_x, mouse_y)
    [
      (mouse_x - @width_borde).div(@width_casilla) + 1,
      (mouse_y - @width_borde).div(@width_casilla) + 1
    ]
  end

  def draw(tablero, focus)
    (1..8).each do |columna|
      (1..8).each do |fila|
        if focus&.eql?(tablero[columna][fila])
          color = Color::BLUE
        else
          color = (columna + fila).even? ? Color::WHITE : Color::RED
        end

        draw_casilla(tablero, columna, fila, color)
      end
    end

    if focus
      focus.jugadas_posibles.each do |columna, fila|
        draw_casilla(tablero, columna, fila, Color::CYAN)
      end
    end

    if tablero.jaque_mate?
      Image.from_text("Ganaron las #{tablero.jugador_siguiente}.", 20).draw(10, 570, 0)
    end

    if tablero.ahogado?
      Image.from_text("Las #{tablero.jugador} no pueden hacer ningún movimiento. La partida termina en empate.", 20).draw(10, 570, 0)
    end

    unless tablero.suficientes_piezas?
      Image.from_text("No hay suficientes piezas para continuar. La partida termina en empate.", 20).draw(10, 570, 0)
    end
  end

  def draw_casilla(tablero, columna, fila, color)
    extremo_x = @width_casilla * (columna - 1) + @width_borde
    extremo_y = @width_casilla * (fila - 1) + @width_borde

    draw_rect(extremo_x, extremo_y, @width_casilla, @width_casilla, color)

    tablero[columna][fila].tap do |pieza|
      ImagesPiezas.draw(pieza.class, pieza.color, extremo_x, extremo_y, @width_casilla) if pieza
    end
  end
end

class ScreenCoronar
  def initialize
    @inicio = 40
    @separacion = 40
    @width = 100
    @pos_y = 250
    @piezas = [Alfil, Caballo, Dama, Torre]
  end

  def draw(jugador)
    Image.from_text("Elegi la pieza a la que va a coronar el peon", 25).draw(50, 200, 0)

    @piezas.each_with_index do |pieza, i|
      pos_x = @inicio + i * (@width + @separacion)
      draw_rect(pos_x, @pos_y, @width, @width, Color::WHITE)
      ImagesPiezas.draw(pieza, jugador, pos_x, @pos_y, @width)
    end
  end

  def choose(mouse_x, mouse_y)
    Thread.current[:choose] = nil

    if (@pos_y..(@pos_y + @width)).include?(mouse_y)
      @piezas.each_with_index do |pieza, i|
        pos_x = @inicio + i * (@width + @separacion)
        Thread.current[:choose] = pieza.to_s.gsub(/Ajedrez::/, "").chr if (pos_x..pos_x + @width).include?(mouse_x)
      end
    end

    Thread.current[:choose]
  end
end
