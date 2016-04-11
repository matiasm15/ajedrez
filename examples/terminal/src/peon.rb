class Ajedrez::Peon
  def _coronar
    loop do
      print "Que pieza quiere (D/A/C/T)? "
      eleccion = gets.strip.upcase

      return eleccion if %w(D A C T).include?(eleccion)

      print "Movimiento no valido: pieza incorrecta.\n\n"
    end
  end
end
