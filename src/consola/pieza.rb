class Pieza
  def to_s
    (@color == BLANCAS) ? inicial.white_on_red : inicial.black_on_red
  end
end

class Peon < Pieza
  def coronar
    loop do
      print "Que pieza quiere (D/A/C/T)? "
      eleccion = gets.strip
      begin
        return __coronar__(eleccion)
      rescue ArgumentError
        puts "Pieza incorrecta."
      end
    end
  end
end
