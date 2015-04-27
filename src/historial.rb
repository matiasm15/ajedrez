class Historial < Array
  def mostrar
    if empty?
      print "El historial esta vacio.\n"
    else
      each_with_index { |jugada, i|
        encabezado = i.even? ? (i + 2).div(2).to_s.concat(".")  : ""
        puts encabezado.ljust(5).concat(jugada)
      }
    end

    print "\n"
  end
end
