require 'colored'
require 'gosu'
require 'set'
require_relative '../core/ajedrez'
require_relative 'tablero'
include Gosu

class Game < Window
  def initialize
    super(600, 600)
    self.caption = "Ajedrez"

    $tablero = Tablero.crear(60, 60, 60, 60)
    $tablero.colocar_piezas

    @pieza_columna = 0
    @pieza_fila = 0
    @activo = false
    @dibujar = true
    @set_posiciones = (1..8).to_a.repeated_permutation(2).to_set
  end

  def draw_pieza(pieza, x, y)
    @pict_piezas ||= {
      Rey => {
          BLANCAS => Image.load_tiles("chess.png", 333, 333).at(0),
          NEGRAS => Image.load_tiles("chess.png", 333, 333).at(6)
        },
      Dama => {
          BLANCAS => Image.load_tiles("chess.png", 333, 333).at(1),
          NEGRAS => Image.load_tiles("chess.png", 333, 333).at(7)
        },
      Alfil => {
          BLANCAS => Image.load_tiles("chess.png", 333, 333).at(2),
          NEGRAS => Image.load_tiles("chess.png", 333, 333).at(8)
        },
      Caballo => {
          BLANCAS => Image.load_tiles("chess.png", 333, 333).at(3),
          NEGRAS => Image.load_tiles("chess.png", 333, 333).at(9)
        },
      Torre => {
          BLANCAS => Image.load_tiles("chess.png", 333, 333).at(4),
          NEGRAS => Image.load_tiles("chess.png", 333, 333).at(10)
        },
      PeonBlanco => {
          BLANCAS => Image.load_tiles("chess.png", 333, 333).at(5)
        },
      PeonNegro => {
          NEGRAS => Image.load_tiles("chess.png", 333, 333).at(11)
        }
    }

    @pict_piezas[pieza.class][pieza.color].draw(x, y, 0, 0.18, 0.18)
  end

  def draw
    @dibujar = false

    $tablero.draw(self, @pieza_columna, @pieza_fila)
  end

  def update
    if button_down?(Gosu::MsLeft)
      pieza_fila = mouse_y.fdiv(60).truncate
      pieza_columna = mouse_x.fdiv(60).truncate

      if [pieza_fila, pieza_columna].any? { |limite| !(1..8).include?(limite) }
        puts "[Error] Posicion (#{pieza_columna},#{pieza_fila}) no valida."

        @pieza_fila = 0
        @pieza_columna = 0
        @activo = false
      elsif @activo and $tablero[@pieza_columna][@pieza_fila].puede_moverse?(pieza_columna, pieza_fila)
        puts "Pieza movida (#{@pieza_columna},#{@pieza_fila}) a (#{pieza_columna},#{pieza_fila})."

        $tablero.mover(@pieza_columna, @pieza_fila, pieza_columna, pieza_fila)
        @pieza_fila = 0
        @pieza_columna = 0
        @activo = false
      elsif !$tablero[pieza_columna][pieza_fila].nil? and $tablero[pieza_columna][pieza_fila].color == $tablero.jugador
        puts "Seleccionada pieza (#{pieza_columna},#{pieza_fila})."

        @pieza_fila = pieza_fila
        @pieza_columna = pieza_columna
        @activo = true
      else
        puts "[Error] Posicion (#{pieza_columna},#{pieza_fila}) no valida para pieza (#{@pieza_columna},#{@pieza_fila})."

        @pieza_fila = 0
        @pieza_columna = 0
        @activo = false
      end

      @dibujar = true
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
