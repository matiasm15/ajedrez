require 'colored'
require 'gosu'
require_relative '../core/ajedrez'
require_relative 'tablero'
include Gosu

class Game < Window
  def initialize
    super(600, 600)
    self.caption = "Ajedrez"

    $tablero = Tablero.crear(60, 60, 60, 60)
    $tablero.colocar_piezas

    @dibujar = true

    @pieza_activa = false
    @pieza_fila = nil
    @pieza_columna = nil
  end

  def draw_pieza(pieza, x, y)
    @pict_piezas ||= {
      Rey => {
          BLANCAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(0),
          NEGRAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(6)
        },
      Dama => {
          BLANCAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(1),
          NEGRAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(7)
        },
      Alfil => {
          BLANCAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(2),
          NEGRAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(8)
        },
      Caballo => {
          BLANCAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(3),
          NEGRAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(9)
        },
      Torre => {
          BLANCAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(4),
          NEGRAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(10)
        },
      PeonBlanco => {
          BLANCAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(5)
        },
      PeonNegro => {
          NEGRAS => Image.load_tiles("./graphics/chess.png", 333, 333).at(11)
        }
    }

    @pict_piezas[pieza.class][pieza.color].draw(x, y, 0, 0.18, 0.18)
  end

  def draw
    @dibujar = false

    $tablero.draw(self, @pieza_columna, @pieza_fila)
  end

  def button_up(button)
    if button.eql?(Gosu::MsLeft)
      @dibujar = true

      pieza_fila = mouse_y.div(60)
      pieza_columna = mouse_x.div(60)

      begin
        if @pieza_activa and $tablero[@pieza_columna][@pieza_fila].puede_moverse?(pieza_columna, pieza_fila)
          $tablero.mover(@pieza_columna, @pieza_fila, pieza_columna, pieza_fila)
        elsif !$tablero[pieza_columna][pieza_fila].nil? and $tablero[pieza_columna][pieza_fila].color.eql?($tablero.jugador)

          # Le doy el focus a la nueva posicion en caso que no lo tenga. Si ya lo tuviera lo pierde.
          if !@pieza_columna.eql?(pieza_columna) or !@pieza_fila.eql?(pieza_fila)
            @pieza_activa = true
            @pieza_fila = pieza_fila
            @pieza_columna = pieza_columna

            return
          end

        end
      rescue Exception
      end

      @pieza_activa = false
      @pieza_fila = nil
      @pieza_columna = nil
    end
  end

  def needs_cursor?
    true
  end

  def needs_redraw?
    @dibujar
  end
end

Game.new.show
