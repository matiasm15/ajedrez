class Tablero < Hash
  def mostrar
    print "\n  a b c d e f g h\n"

    8.downto(1) do |fila|
      print "#{fila} "
      (1..8).each do |columna|
        if self[columna][fila].nil?
          print "-".cyan_on_red
        else
          print "#{self[columna][fila]}"
        end

        print " ".on_red if columna != 8
      end

      print "\n"
    end
    print "\n"

    self
  end

  def iniciar
    colocar_piezas.mostrar
  end
end
