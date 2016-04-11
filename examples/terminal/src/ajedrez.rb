require 'colored'

require_relative '../../../lib/ajedrez'
require_relative 'peon'
require_relative 'commander'

include Ajedrez

class String
  def to_num
    ord - 96
  end
end

class Game
  def initialize
    @tablero = Tablero.new
    @commander = Commander.new
  end

  def start
    @commander.tablero(@tablero.colocar_piezas)

    puts "Bienvenidos! Ante cualquier duda sobre las instrucciones escriba \"ayuda\"."
    loop do
      print ">> "
      instruccion = gets.strip.downcase

      case
        when /\Ah(istorial)?\z/.match(instruccion)
          @commander.historial(@tablero.historial)

        when /\At(ablero)?\z/.match(instruccion)
          @commander.tablero(@tablero)

        when /\Ar(einiciar)?\z/.match(instruccion)
          @tablero = Tablero.new.colocar_piezas
          @commander.tablero(@tablero)

        when /\Aj(ugador)?\z/.match(instruccion)
          @commander.jugador(@tablero)

        when /\Aa(yuda)?\z/.match(instruccion)
          @commander.ayuda

        when posiciones = /\Am(over)?\s+([a-h])([1-8])\s+([a-h])([1-8])\z/.match(instruccion)
          @commander.mover(@tablero, posiciones)

        when /\As(alir)?\z/.match(instruccion)
          break

        else
          print "Instruccion incorrecta.\n\n"

      end
    end
  end
end

Game.new.start
