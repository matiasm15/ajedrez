require 'colored'
require_relative 'historial'
require_relative 'tablero'
require_relative 'pieza'

Blanca = :blancas
Negra = :negras

class Object
  def deep_clone
    Marshal::load(Marshal::dump(self))
  end
end

class Fixnum
  def to_lttr
    (self + 96).chr
  end
end

class String
  def to_num
    self.ord - 96
  end
end

def ayuda
  puts "(m)over <pos_ini> <pos_fin>:  mueve una pieza del tablero dada una posicion inicial y otra final."
  puts "(h)istorial:                  muestra el historial de la partida."
  puts "(t)ablero:                    muestra el tablero."
  puts "(r)einiciar:                  reinicia la partida."
  puts "(j)ugador:                    muestra el jugador que tiene el turno para mover."
  puts "(a)yuda:                      muestra esta ayuda."
  puts "(s)alir:                      sale del juego."
  print "\n"
end

if __FILE__ == $0
  puts "Bienvenidos! Ante cualquier duda sobre las instrucciones escriba \"ayuda\"."
  $tablero = Tablero.new
  $tablero.iniciar

  while true
    print ">> "
    instruccion = gets.strip.downcase
    case
      when /\Ah(istorial)?\z/.match(instruccion)
        $tablero.historial.mostrar
      when /\At(ablero)?\z/.match(instruccion)
        $tablero.mostrar
      when /\Ar(einiciar)?\z/.match(instruccion)
        $tablero = Tablero.new
        $tablero.iniciar
      when /\Aj(ugador)?\z/.match(instruccion)
        print "Deben mover las " + $tablero.jugador_actual.to_s + ".\n\n"
      when /\Aa(yuda)?\z/.match(instruccion)
        ayuda
      when match_data = /\Am(over)?\s+([a-h])([1-8])\s+([a-h])([1-8])\z/.match(instruccion)
        $tablero.mover(match_data[2].to_num, match_data[3].to_i, match_data[4].to_num, match_data[5].to_i)
      when /\As(alir)?\z/.match(instruccion)
        exit
      else
        print "Instruccion incorrecta.\n\n"
    end
  end
end
