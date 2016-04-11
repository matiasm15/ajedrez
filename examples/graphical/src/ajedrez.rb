require 'colored'
require 'gosu'

require_relative '../../../lib/ajedrez'
require_relative 'peon'
require_relative 'screens'

include Gosu
include Ajedrez

class Game < Window
  def initialize
    width_borde = 60
    width_casilla = 60
    width_window = width_borde * 2 + width_casilla * 8

    @mover = Thread.new {}
    @needs_redraw = true
    @tablero = Tablero.new.colocar_piezas

    @screen_coronar = ScreenCoronar.new
    @screen_tablero = ScreenTablero.new(width_borde, width_casilla)

    super(width_window, width_window)
    self.caption = "Ajedrez"
  end

  def draw
    @needs_redraw = false

    if @mover.alive?
      @screen_coronar.draw(@tablero.jugador)
    else
      @screen_tablero.draw(@tablero, @focus)
    end
  end

  def button_up(button)
    close if button.eql?(Gosu::KbEscape)

    if @mover.alive?
      if button.eql?(Gosu::MsLeft)
        @mover.run if @screen_coronar.choose(mouse_x, mouse_y)
      end

      return
    end

    return unless @tablero.se_puede_jugar?

    if button.eql?(Gosu::MsLeft)
      @needs_redraw = true
      columna, fila = @screen_tablero.casilla(mouse_x, mouse_y)

      begin
        if @focus and @focus.puede_moverse?(columna, fila)
          @mover = Thread.new do
            @tablero.mover(@focus.columna, @focus.fila, columna, fila)
            @needs_redraw = true
          end

          @mover.join(0.05) until @mover.stop?
        elsif @tablero[columna][fila] and @tablero[columna][fila].color.eql?(@tablero.jugador)
          # Le doy el focus a la nueva posicion en caso que no lo tenga. Si ya lo tuviera lo pierde.
          unless @focus.eql?(@tablero[columna][fila])
            @focus = @tablero[columna][fila]
            return
          end
        end
      rescue KeyError; end

      @focus = nil
    end
  end

  def needs_cursor?
    true
  end

  def needs_redraw?
    @needs_redraw
  end
end

Game.new.show
