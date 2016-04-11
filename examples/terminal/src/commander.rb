class Commander
  def historial(historial)
    if historial.empty?
      print "El historial esta vacio.\n"
    else
      historial.each_with_index do |jugada, i|
        encabezado = i.even? ? (i + 2).div(2).to_s.concat(".") : ""
        puts encabezado.ljust(5).concat(jugada)
      end
    end

    print "\n"
  end

  def tablero(tablero)
    print "\n  a b c d e f g h\n"

    8.downto(1) do |fila|
      print "#{fila} "
      (1..8).each do |columna|
        if tablero[columna][fila]
          if tablero[columna][fila].color == Blancas
            print tablero[columna][fila].inicial.white_on_red
          else
            print tablero[columna][fila].inicial.black_on_red
          end
        else
          print "-".cyan_on_red
        end

        print " ".on_red unless columna == 8
      end

      print "\n"
    end

    print "\n"
  end

  def jugador(tablero)
    if tablero.se_puede_jugar?
      print "Deben mover las #{tablero.jugador}.\n\n"
    else
      print "La partida ha terminado. Escriba reiniciar para jugar otra.\n\n"
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

  def mover(tablero, posiciones)
    if tablero.se_puede_jugar?
      begin
        tablero.mover(posiciones[2].to_num, posiciones[3].to_i, posiciones[4].to_num, posiciones[5].to_i)

        self.tablero(tablero)

        if tablero.jaque_mate?
          print "Jaque mate, ganaron las #{tablero.jugador_siguiente}.\n\n"
        elsif tablero.ahogado?
          print "No existe una jugadas posible para las #{tablero.jugador}, la partida termina en tablas.\n\n"
        elsif !tablero.suficientes_piezas?
          print "No existen suficientes piezas para generar un jaque mate, la partida termina en tablas.\n\n"
        end
      rescue MovimientoInvalido
        print "Movimiento no valido: " + $!.to_s + ".\n\n"
      end
    else
      print "La partida ha terminado. Escriba reiniciar para jugar otra.\n\n"
    end
  end
end
