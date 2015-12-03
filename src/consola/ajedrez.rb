require 'colored'
require_relative '../core/ajedrez'
require_relative 'historial'
require_relative 'tablero'
require_relative 'pieza'

class Game
  def initialize
    $tablero = Tablero.new
  end

  def show
    $tablero.iniciar

    puts "Bienvenidos! Ante cualquier duda sobre las instrucciones escriba \"ayuda\"."
    loop do
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
          if $tablero.se_puede_jugar?
            print "Deben mover las #{$tablero.jugador}.\n\n"
          else
            print "La partida ha terminado. Escriba reiniciar para jugar otra.\n\n"
          end

        when /\Aa(yuda)?\z/.match(instruccion)
          ayuda

        when match_data = /\Am(over)?\s+([a-h])([1-8])\s+([a-h])([1-8])\z/.match(instruccion)
          if $tablero.se_puede_jugar?
            begin
              $tablero.mover(match_data[2].to_num, match_data[3].to_i, match_data[4].to_num, match_data[5].to_i).mostrar
              
              if $tablero.jaque_mate?
                print "Jaque mate, ganaron las #{$tablero.jugador_siguiente}.\n\n"
              elsif $tablero.ahogado?
                print "No existe una jugadas posible para las #{$tablero.jugador}, la partida termina en tablas.\n\n"
              elsif !$tablero.suficientes_piezas?
                print "No existen suficientes piezas para generar un jaque mate, la partida termina en tablas.\n\n"
              end
            rescue MovimientoInvalido
              print $!
              print "\n\n"
            end
          else
            print "La partida ha terminado. Escriba reiniciar para jugar otra.\n\n"
          end

        when /\As(alir)?\z/.match(instruccion)
          break

        else
          print "Instruccion incorrecta.\n\n"

      end
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
end

Game.new.show
