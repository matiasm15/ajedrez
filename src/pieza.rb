# Modulo de las piezas que realizan sus movimientos de forma horizontal, vertical o diagonal.
module Movil
  def camino_libre?(pos_inicial, pos_final, &block)
    (([pos_inicial, pos_final].min.succ)..([pos_inicial, pos_final].max.pred)).all? do |i|
      block.call(i)
    end
  end
end

module MovilLineal
  include Movil

  def puede_desplazarse?(columna, fila)
    (@fila == fila and camino_horizontal_libre?(columna)) or (@columna == columna and camino_vertical_libre?(fila))
  end

  def camino_horizontal_libre?(columna)
    camino_libre?(columna, @columna) { |i| $tablero[i][@fila].nil? }
  end

  def camino_vertical_libre?(fila)
    camino_libre?(fila, @fila) { |i| $tablero[@columna][i].nil? }
  end
end

module MovilDiagonal
  include Movil

  def puede_desplazarse?(columna, fila)
    (@fila - fila).abs == (@columna - columna).abs and camino_diagonal_libre?(columna, fila)
  end

  def camino_diagonal_libre?(columna, fila)
    camino_libre?(columna, @columna) do |i|
      j = if (@columna > columna and @fila < fila) or (@columna < columna and @fila > fila)
            [fila, @fila].max + [columna, @columna].min - i
          else
            [fila, @fila].min - [columna, @columna].min + i
          end

      $tablero[i][j].nil?
    end
  end
end

class Pieza
  attr_reader :color, :columna, :fila

  def initialize(color, columna, fila)
    @color = color
    @columna = columna
    @fila = fila
    @se_movio = false
    $tablero[@columna][@fila] = self
  end

  def se_movio?
    @se_movio
  end

  def inicial
    self.class.to_s.chr
  end

  def to_s
    (@color == BLANCAS) ? inicial.white_on_red : inicial.black_on_red
  end

  def notacion(columna, fila)
    ambiguedades = $tablero.movibles_a(columna, fila).select do |pieza|
      (@columna != pieza.columna or @fila != pieza.fila) and @color == pieza.color and self.class == pieza.class
    end

    notacion = inicial
    if ambiguedades.any? { |pieza| @fila == pieza.fila } and ambiguedades.any? { |pieza| @columna == pieza.columna }
      notacion << "#{@columna.to_lttr}#{@fila}"
    elsif ambiguedades.any? { |pieza| @columna == pieza.columna }
      notacion << "#{@fila}"
    elsif !ambiguedades.empty?
      notacion << "#{@columna.to_lttr}"
    end

    notacion << "x" unless $tablero[columna][fila].nil?
    notacion << "#{columna.to_lttr}#{fila}"
  end

  def mover(columna, fila)
    $tablero[@columna][@fila] = nil
    @columna = columna
    @fila = fila
    @se_movio = true
    $tablero.captura_al_paso = 0
    $tablero[@columna][@fila] = self
  end

  def existe_jugada_posible?
    !jugadas_posibles.empty?
  end

  def jugadas_posibles
    jugadas_posibles = []

    (1..8).each do |columna|
      (1..8).each do |fila|
        jugadas_posibles << [columna, fila] if puede_moverse?(columna, fila)
      end
    end

    jugadas_posibles
  end

  # Clono el tablero para simular el movimiento y comprobar si el jugador estara en jaque.
  def jaque?(columna = @columna, fila = @fila)
    tablero_original = $tablero
    $tablero = $tablero.deep_clone
    $tablero.test = true
    $tablero[@columna][@fila].mover(columna, fila).cumple_condicion_para_jaque?
  ensure
    $tablero = tablero_original
  end

  def cumple_condicion_para_jaque?
    $tablero.jaque?(@color)
  end

  def puede_moverse?(columna, fila)
    $tablero[columna][fila].nil? or $tablero[columna][fila].color != @color and puede_desplazarse?(columna, fila) and !jaque?(columna, fila)
  end

  def puede_atacar?(columna, fila)
    puede_desplazarse?(columna, fila)
  end

  def puede_enrocar?(_rey = nil)
    false
  end

  def rey?(_color = @color)
    false
  end

  def torre?(_color = @color)
    false
  end
end

class Rey < Pieza
  def notacion(columna, fila)
    if puede_enrocar_corto?(columna, fila)
      "0+0"
    elsif puede_enrocar_largo?(columna, fila)
      "0+0+0"
    else
      super
    end
  end

  def mover(columna, fila)
    unless $tablero.test?  # Para evitar un ciclo infinito.
      if puede_enrocar_largo?(columna, fila)
        $tablero[1][fila].mover(4, fila)
      elsif puede_enrocar_corto?(columna, fila)
        $tablero[8][fila].mover(6, fila)
      end
    end

    super
  end

  def puede_enrocar?(columna, fila)
    puede_enrocar_largo?(columna, fila) or puede_enrocar_corto?(columna, fila)
  end

  def puede_enrocar_largo?(columna, fila)
    fila == @fila and columna == 3 and !se_movio? and !jaque? and !jaque?(4, fila) and
      !$tablero[1][fila].nil? and $tablero[1][fila].puede_enrocar?(self)
  end

  def puede_enrocar_corto?(columna, fila)
    fila == @fila and columna == 7 and !se_movio? and !jaque? and !jaque?(6, fila) and
      !$tablero[8][fila].nil? and $tablero[8][fila].puede_enrocar?(self)
  end

  def cumple_condicion_para_jaque?
    $tablero.puede_ser_atacado?(@columna, @fila, @color)
  end

  def puede_desplazarse?(columna, fila)
    puede_atacar?(columna, fila) or puede_enrocar?(columna, fila)
  end

  def puede_atacar?(columna, fila)
    (@columna - columna).abs <= 1 and (@fila - fila).abs <= 1
  end

  def rey?(color = @color)
    color == @color
  end
end

class Dama < Pieza
  include MovilLineal
  alias_method :puede_desplazarse_linealmente?, :puede_desplazarse?

  include MovilDiagonal
  alias_method :puede_desplazarse_diagonalmente?, :puede_desplazarse?

  def puede_desplazarse?(columna, fila)
    puede_desplazarse_linealmente?(columna, fila) or puede_desplazarse_diagonalmente?(columna, fila)
  end
end

class Torre < Pieza
  include MovilLineal

  def torre?(color = @color)
    color == @color
  end

  def puede_enrocar?(rey)
    rey.color == @color and !se_movio? and camino_horizontal_libre?(rey.columna)
  end
end

class Caballo < Pieza
  def puede_desplazarse?(columna, fila)
    ((@columna - columna).abs == 2 and (@fila - fila).abs == 1) or ((@columna - columna).abs == 1 and (@fila - fila).abs == 2)
  end
end

class Alfil < Pieza
  include MovilDiagonal
end

class Peon < Pieza
  def notacion(columna, fila)
    if puede_atacar?(columna, fila)
      "#{@columna.to_lttr}x#{columna.to_lttr}#{fila}"
    elsif puede_capturar_al_paso?(columna, fila)
      "#{@columna.to_lttr}x#{columna.to_lttr}#{fila}e.p."
    else
      "#{columna.to_lttr}#{fila}"
    end
  end

  def mover(columna, fila)
    if @fila == fila_inicial and fila == fila_doble_avance
      $tablero.captura_al_paso = columna
    else
      $tablero[columna][@fila] = nil if puede_capturar_al_paso?(columna, fila)
      $tablero.captura_al_paso = 0
    end

    $tablero[@columna][@fila] = nil
    @columna = columna
    @fila = fila
    $tablero[columna][fila] = (!$tablero.test? and @fila == fila_final) ? coronar : self
  end

  def coronar
    loop do
      print "Que pieza quiere (D/A/C/T)? "
      eleccion = gets.strip
      case eleccion
        when "D"
          return Dama.new(@color, @columna, @fila)
        when "A"
          return Alfil.new(@color, @columna, @fila)
        when "C"
          return Caballo.new(@color, @columna, @fila)
        when "T"
          return Torre.new(@color, @columna, @fila)
        else
          puts "Pieza incorrecta."
      end
    end
  ensure
    $tablero.notacion << "#{eleccion}="
  end

  def puede_moverse?(columna, fila)
    puede_desplazarse?(columna, fila) or puede_atacar?(columna, fila) or puede_capturar_al_paso?(columna, fila) and !jaque?(columna, fila)
  end

  def puede_desplazarse?(columna, fila)
    $tablero[columna][fila].nil? and @columna == columna and
      (fila_inicial == @fila and fila_doble_avance == fila and $tablero[columna][fila_siguiente].nil? or fila_siguiente == fila)
  end

  def puede_atacar?(columna, fila)
    !$tablero[columna][fila].nil? and $tablero[columna][fila].color != @color and (@columna - columna).abs == 1 and fila_siguiente == fila
  end

  def puede_capturar_al_paso?(columna, fila)
    $tablero.captura_al_paso == columna and (@columna - columna).abs == 1 and fila_avanzada(fila_inicial, 3) == @fila and fila_siguiente == fila
  end

  def fila_avanzada(fila = @fila, posiciones)
    posiciones.zero? ? fila : fila_avanzada(fila_siguiente(fila), posiciones.pred)
  end

  def fila_doble_avance
    fila_avanzada(fila_inicial, 2)
  end

  def fila_final
    fila_avanzada(fila_inicial, 6)
  end
end

class PeonBlanco < Peon
  def initialize(columna, fila)
    super(BLANCAS, columna, fila)
  end

  def fila_siguiente(fila = @fila)
    fila.succ
  end

  def fila_inicial
    2
  end
end

class PeonNegro < Peon
  def initialize(columna, fila)
    super(NEGRAS, columna, fila)
  end

  def fila_siguiente(fila = @fila)
    fila.pred
  end

  def fila_inicial
    7
  end
end
