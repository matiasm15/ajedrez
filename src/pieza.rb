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
    (@color == Blanca) ? inicial.white_on_red : inicial.black_on_red
  end

  def notacion_jugada(columna, fila)
    posibles_ambiguedades = $tablero.piezas_que_pueden_moverse_a(columna, fila).select { |pieza|
      (@columna != pieza.columna or @fila != pieza.fila) and @color == pieza.color and self.class == pieza.class
    }

    notacion = inicial

    if posibles_ambiguedades.any? { |pieza| @fila == pieza.fila } and posibles_ambiguedades.any? { |pieza| @columna == pieza.columna }
      notacion << @columna.to_lttr + @fila.to_s
    elsif posibles_ambiguedades.any? { |pieza| @columna == pieza.columna }
      notacion << @fila.to_s
    elsif posibles_ambiguedades.any?
      notacion << @columna.to_lttr
    end
    unless $tablero[columna][fila].nil?
      notacion << "x"
    end

    notacion << columna.to_lttr + fila.to_s
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
    jugadas_posibles = Array.new

    for columna in 1..8
      for fila in 1..8
        if puede_moverse?(columna, fila)
          jugadas_posibles << [columna, fila]
        end
      end
    end

    jugadas_posibles
  end 

  def simular(columna, fila, &block)
    columna_aux = @columna
    fila_aux = @fila
    se_movio_aux = @se_movio
    tablero_original = $tablero
    $tablero = $tablero.deep_clone
    $tablero.en_pruebas = true
    mover(columna, fila)

    block.call
  ensure
    $tablero = tablero_original
    @columna = columna_aux
    @fila = fila_aux
    @se_movio = se_movio_aux
  end

  def en_jaque?(columna = @columna, fila = @fila)
    simular(columna, fila) {cumple_condicion_para_jaque?}
  end

  def cumple_condicion_para_jaque?
    $tablero.jugador_en_jaque?(@color)
  end

  def puede_desplazarse_linealmente?(columna, fila)
    (@fila == fila and camino_horizontal_libre?(columna)) or (@columna == columna and camino_vertical_libre?(fila))
  end

  def camino_horizontal_libre?(columna)
    if (@columna - columna).abs > 1
      for i in ([columna, @columna].min + 1)..([columna, @columna].max - 1)
        unless $tablero[i][@fila].nil?
          return false
        end
      end
    end

    return true
  end

  def camino_vertical_libre?(fila)
    if (@fila - fila).abs > 1
      for i in ([fila, @fila].min + 1)..([fila, @fila].max - 1)
        unless $tablero[@columna][i].nil?
          return false
        end
      end
    end

    return true
  end

  def puede_desplazarse_diagonalmente?(columna, fila)
    (@fila - fila).abs == (@columna - columna).abs and camino_diagonal_libre?(columna, fila)
  end

  def camino_diagonal_libre?(columna, fila)
    if (@columna - columna).abs > 1
      for i in ([columna, @columna].min + 1)..([columna, @columna].max - 1)
        j = if (@columna > columna and @fila < fila) or (@columna < columna and @fila > fila)
          [fila, @fila].max + [columna, @columna].min - i
        else
          [fila, @fila].min - [columna, @columna].min + i
        end

        unless $tablero[i][j].nil?
          return false
        end
      end
    end

    return true
  end

  def puede_moverse?(columna, fila)
    ($tablero[columna][fila].nil? or $tablero[columna][fila].color != @color) and puede_desplazarse?(columna, fila) and !en_jaque?(columna, fila)
  end

  def puede_atacar?(columna, fila)
    puede_desplazarse?(columna, fila)
  end

  def rey?(color = @color)
    false
  end

  def torre?(color = @color)
    false
  end
end

class Rey < Pieza
  def notacion_jugada(columna, fila)
    if puede_enrocar_corto?(columna, fila)
      "0+0"
    elsif puede_enrocar_largo?(columna, fila)
      "0+0+0"
    else
      super
    end
  end

  def mover(columna, fila)
    unless $tablero.en_pruebas?  # Para evitar un ciclo infinito.
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
    !se_movio? and @fila == fila and !en_jaque? and columna == 3 and !$tablero[1][fila].nil? and
    $tablero[1][fila].torre?(@color) and !$tablero[1][fila].se_movio? and camino_horizontal_libre?(1) and !en_jaque?(4, fila)
  end

  def puede_enrocar_corto?(columna, fila)
    !se_movio? and @fila == fila and !en_jaque? and columna == 7 and !$tablero[8][fila].nil? and
    $tablero[8][fila].torre?(@color) and !$tablero[8][fila].se_movio? and camino_horizontal_libre?(8) and !en_jaque?(6, fila)
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
  def puede_desplazarse?(columna, fila)
    puede_desplazarse_linealmente?(columna, fila) or puede_desplazarse_diagonalmente?(columna, fila)
  end
end

class Torre < Pieza
  def puede_desplazarse?(columna, fila)
    puede_desplazarse_linealmente?(columna, fila)
  end

  def torre?(color = @color)
    color == @color
  end
end

class Caballo < Pieza
  def puede_desplazarse?(columna, fila)
    ((@columna - columna).abs == 2 and (@fila - fila).abs == 1) or ((@columna - columna).abs == 1 and (@fila - fila).abs == 2)
  end
end

class Alfil < Pieza
  def puede_desplazarse?(columna, fila)
    puede_desplazarse_diagonalmente?(columna, fila)
  end
end

class Peon < Pieza
  def notacion_jugada(columna, fila)
    if puede_atacar?(columna, fila)
      @columna.to_lttr + "x" + columna.to_lttr + fila.to_s
    elsif puede_capturar_al_paso?(columna, fila)
      @columna.to_lttr + "x" + columna.to_lttr + fila.to_s + "e.p."
    else
      columna.to_lttr + fila.to_s
    end
  end

  def mover(columna, fila)
    $tablero[@columna][@fila] = nil
    @columna = columna
    @fila = fila
  end

  def coronar
    while true
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
    $tablero.notacion_jugada << eleccion + "="
  end

  def puede_moverse?(columna, fila)
    (puede_desplazarse?(columna, fila) or puede_atacar?(columna, fila) or puede_capturar_al_paso?(columna, fila)) and !en_jaque?(columna, fila)
  end

  def puede_desplazarse?(columna, fila)
    $tablero[columna][fila].nil? and @columna == columna
  end

  def puede_atacar?(columna, fila)
    !$tablero[columna][fila].nil? and $tablero[columna][fila].color != @color and (@columna - columna).abs == 1
  end

  def puede_capturar_al_paso?(columna, fila)
    columna == $tablero.captura_al_paso and (@columna - columna).abs == 1
  end
end

class PeonBlanco < Peon
  def initialize(columna, fila)
    super(Blanca, columna, fila)
  end

  def mover(columna, fila)
    if @fila == 2 and fila == 4
      $tablero.captura_al_paso = columna
    else
      if puede_capturar_al_paso?(columna, fila)
        $tablero[columna][fila - 1] = nil
      end

      $tablero.captura_al_paso = 0
    end

    super

    $tablero[columna][fila] = (!$tablero.en_pruebas? and @fila == 8) ? coronar : self
  end

  def puede_desplazarse?(columna, fila)
    super and ((@fila + 1) == fila or (@fila == 2 and fila == 4 and $tablero[columna][3].nil?))
  end

  def puede_atacar?(columna, fila)
    super and (@fila + 1) == fila
  end

  def puede_capturar_al_paso?(columna, fila)
    super and @fila == 5 and fila == 6 
  end
end

class PeonNegro < Peon
  def initialize(columna, fila)
    super(Negra, columna, fila)
  end

  def mover(columna, fila)
    if @fila == 7 and fila == 5
      $tablero.captura_al_paso = columna
    else
      if puede_capturar_al_paso?(columna, fila)
        $tablero[columna][fila + 1] = nil
      end

      $tablero.captura_al_paso = 0
    end

    super

    $tablero[columna][fila] = (!$tablero.en_pruebas? and @fila == 1) ? coronar : self
  end

  def puede_desplazarse?(columna, fila)
    super and ((@fila - 1) == fila or (@fila == 7 and fila == 5 and $tablero[columna][6].nil?))
  end

  def puede_atacar?(columna, fila)
    super and (@fila - 1) == fila
  end

  def puede_capturar_al_paso?(columna, fila)
    super and @fila == 4 and fila == 3
  end
end
