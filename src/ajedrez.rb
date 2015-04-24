require 'colored'

Blanca = :blancas
Negra = :negras

$en_pruebas = false

def en_pruebas?
  $en_pruebas
end

def historial
  $historial.mostrar
end

def tablero
  $tablero.mostrar
end

def reiniciar
  $historial = Historial.new
  $captura_al_paso = 0
  $jugador_actual = Blanca

  $tablero = Tablero.new
  $tablero.colocar_piezas.mostrar
end

def mover(posicion_anterior, posicion_siguiente)
  columna_anterior, fila_anterior = posicion_anterior
  columna_siguiente, fila_siguiente = posicion_siguiente

  if [columna_anterior, fila_anterior, columna_siguiente, fila_siguiente].any? { |limite| !(1..8).include?(limite) }
    puts "Movimiento no valido: coordenadas fuera de los limites"
    return
  end

  if $tablero[columna_anterior][fila_anterior].nil?
    puts "Movimiento no valido: pieza inexistente"
    return
  end
  
  if $tablero[columna_anterior][fila_anterior].color != $jugador_actual
    puts "Movimiento no valido: turno incorrecto"
    return
  end

  unless $tablero[columna_anterior][fila_anterior].puede_moverse?(columna_siguiente, fila_siguiente)
    puts "Movimiento no valido"
    return
  end

  $jugador_actual = jugador_siguiente
  $notacion_jugada = $tablero[columna_anterior][fila_anterior].notacion_jugada(columna_siguiente, fila_siguiente)
  $tablero[columna_anterior][fila_anterior].mover(columna_siguiente, fila_siguiente)
  
  $tablero.mostrar
  if jugador_en_jaque_mate?
    puts "Jaque mate, ganaron las #{jugador_siguiente.to_s}"
    $notacion_jugada << "++"
  elsif jugador_en_ahogado?
    puts "No existe una jugadas posible para las #{$jugador_actual.to_s}, la partida termina en tablas"
  elsif !$tablero.existen_suficientes_piezas?
    puts "No existen suficientes piezas para generar un jaque mate, la partida termina en tablas"
  elsif jugador_en_jaque?
    $notacion_jugada << "+"
  end
  $historial << $notacion_jugada

  $notacion_jugada
end

def jugador_siguiente(jugador = $jugador_actual)
  {Blanca => Negra, Negra => Blanca}[jugador]
end

def jugadas_posibles(columna, fila)
  !$tablero[columna][fila].nil? ? $tablero[columna][fila].jugadas_posibles : []
end

def puede_ser_atacado?(columna, fila, jugador = $jugador_actual)
  $tablero.values.any? { |columna_hash|
    columna_hash.values.compact.any? { |pieza|
      pieza.color != jugador and pieza.puede_atacar?(columna, fila)
    }
  }
end

def piezas_que_pueden_moverse_a(columna, fila)
  $tablero.values.collect { |columna_hash|
    columna_hash.values.compact.select { |pieza|
      pieza.puede_moverse?(columna, fila)
    }
  }.flatten
end

def existe_jugada_posible?(jugador = $jugador_actual)
  $tablero.values.any? { |columna_hash|
    columna_hash.values.compact.any? { |pieza|
      pieza.color == jugador and pieza.existe_jugada_posible?
    }
  }
end

def jugador_en_jaque?(jugador = $jugador_actual)
  $tablero.values.any? { |columna_hash|
    columna_hash.values.compact.any? { |pieza|
      pieza.rey?(jugador) and pieza.en_jaque?
    }
  }
end

def jugador_en_jaque_mate?(jugador = $jugador_actual)
  !existe_jugada_posible?(jugador) and jugador_en_jaque?(jugador)
end

def jugador_en_ahogado?(jugador = $jugador_actual)
  !existe_jugada_posible?(jugador) and !jugador_en_jaque?(jugador)
end

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

class Tablero < Hash
  def initialize
    for columna in 1..8
      self[columna] = Hash.new
      for fila in 1..8
        self[columna][fila] = nil
      end
    end
  end

  def colocar_piezas
    for columna in 1..8
      PeonBlanco.new(columna, 2)
      PeonNegro.new(columna, 7)
    end

    Torre.new(Blanca, 1, 1)
    Caballo.new(Blanca, 2, 1)
    Alfil.new(Blanca, 3, 1)
    Dama.new(Blanca, 4, 1)
    Rey.new(Blanca, 5, 1)
    Alfil.new(Blanca, 6, 1)
    Caballo.new(Blanca, 7, 1)
    Torre.new(Blanca, 8, 1)
    Torre.new(Negra, 1, 8)
    Caballo.new(Negra, 2, 8)
    Alfil.new(Negra, 3, 8)
    Dama.new(Negra, 4, 8)
    Rey.new(Negra, 5, 8)
    Alfil.new(Negra, 6, 8)
    Caballo.new(Negra, 7, 8)
    Torre.new(Negra, 8, 8)

    self
  end

  def mostrar
    print "\n  A B C D E F G H\n"

    8.downto(1) { |fila|
      print fila.to_s + " "
      for columna in 1..8
        unless self[columna][fila].nil?
          print self[columna][fila].to_s
        else
          print "-".cyan_on_red
        end

        print " ".on_red if columna != 8
      end

      print "\n"
    }

    print "\n"
  end

  def existen_suficientes_piezas?
    values.any? { |columna_hash|
      columna_hash.values.compact.any? { |pieza|
        !pieza.rey?
      }
    }
  end
end

class Historial < Array
  def mostrar
    unless empty?
      each_with_index { |jugada, i|
        encabezado = i.even? ? (i + 2).div(2).to_s.concat(".")  : ""
        puts encabezado.ljust(5).concat(jugada)
      }
    end

    nil
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
    (@color == Blanca) ? inicial.white_on_red : inicial.black_on_red
  end

  def notacion_jugada(columna, fila)
    posibles_ambiguedades = piezas_que_pueden_moverse_a(columna, fila).select { |pieza|
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
    $captura_al_paso = 0
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
    $en_pruebas = true
    columna_aux = @columna
    fila_aux = @fila
    se_movio_aux = @se_movio
    captura_al_paso_aux = $captura_al_paso
    tableroAux = $tablero.deep_clone
    mover(columna, fila)

    block.call
  ensure
    $en_pruebas = false
    @columna = columna_aux
    @fila = fila_aux
    @se_movio = se_movio_aux
    $captura_al_paso = captura_al_paso_aux
    $tablero = tableroAux.deep_clone
  end

  def en_jaque?(columna = @columna, fila = @fila)
    simular(columna, fila) {cumple_condicion_para_jaque?}
  end

  def cumple_condicion_para_jaque?
    jugador_en_jaque?(@color)
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
    unless en_pruebas?  # Para evitar un ciclo infinito.
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
    puede_ser_atacado?(@columna, @fila, @color)
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
      eleccion = gets.chomp
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
          puts "Pieza incorrecta"
      end
    end
  ensure
    $notacion_jugada << eleccion + "="
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
    columna == $captura_al_paso and (@columna - columna).abs == 1
  end
end

class PeonBlanco < Peon
  def initialize(columna, fila)
    super(Blanca, columna, fila)
  end

  def mover(columna, fila)
    if @fila == 2 and fila == 4
      $captura_al_paso = columna
    else
      if puede_capturar_al_paso?(columna, fila)
        $tablero[columna][fila - 1] = nil
      end

      $captura_al_paso = 0
    end

    super

    $tablero[columna][fila] = (!en_pruebas? and @fila == 8) ? coronar : self
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
      $captura_al_paso = columna
    else
      if puede_capturar_al_paso?(columna, fila)
        $tablero[columna][fila + 1] = nil
      end

      $captura_al_paso = 0
    end

    super

    $tablero[columna][fila] = (!en_pruebas? and @fila == 1) ? coronar : self
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

for columna in 1..8
  for fila in 1..8
    eval("#{columna.to_lttr.upcase}#{fila} = [#{columna}, #{fila}]")
  end
end

reiniciar
