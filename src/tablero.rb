class Tablero < Hash
  attr_reader :jugador_actual, :historial, :notacion_jugada
  attr_accessor :captura_al_paso, :en_pruebas

  def initialize
    @historial = Historial.new
    @jugador_actual = BLANCAS
    @captura_al_paso = 0
    @en_pruebas = false

    self.limpiar  
  end

  def en_pruebas?
    @en_pruebas
  end

  def deep_clone
    Marshal.load(Marshal.dump(self))
  end

  def iniciar
    colocar_piezas.mostrar
  end

  def colocar_piezas
    self.limpiar

    (1..8).each do |columna|
      PeonBlanco.new(columna, 2)
      PeonNegro.new(columna, 7)
    end

    Torre.new(BLANCAS, 1, 1)
    Caballo.new(BLANCAS, 2, 1)
    Alfil.new(BLANCAS, 3, 1)
    Dama.new(BLANCAS, 4, 1)
    Rey.new(BLANCAS, 5, 1)
    Alfil.new(BLANCAS, 6, 1)
    Caballo.new(BLANCAS, 7, 1)
    Torre.new(BLANCAS, 8, 1)
    Torre.new(NEGRAS, 1, 8)
    Caballo.new(NEGRAS, 2, 8)
    Alfil.new(NEGRAS, 3, 8)
    Dama.new(NEGRAS, 4, 8)
    Rey.new(NEGRAS, 5, 8)
    Alfil.new(NEGRAS, 6, 8)
    Caballo.new(NEGRAS, 7, 8)
    Torre.new(NEGRAS, 8, 8)

    self
  end

  def limpiar
    (1..8).each do |columna|
      self[columna] = {}

      (1..8).each do |fila|
        self[columna][fila] = nil
      end
    end

    self
  end

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

  def mover(columna_anterior, fila_anterior, columna_siguiente, fila_siguiente)
    if !se_puede_jugar?
      print "La partida ha terminado. Escriba reiniciar para jugar otra.\n\n"
      return
    end

    if [columna_anterior, fila_anterior, columna_siguiente, fila_siguiente].any? { |limite| !(1..8).include?(limite) }
      print "Movimiento no valido: coordenadas fuera de los limites.\n\n"
      return
    end

    if self[columna_anterior][fila_anterior].nil?
      print "Movimiento no valido: pieza inexistente.\n\n"
      return
    end

    if self[columna_anterior][fila_anterior].color != @jugador_actual
      print "Movimiento no valido: turno incorrecto.\n\n"
      return
    end

    unless self[columna_anterior][fila_anterior].puede_moverse?(columna_siguiente, fila_siguiente)
      print "Movimiento no valido.\n\n"
      return
    end

    @jugador_actual = jugador_siguiente
    @notacion_jugada = self[columna_anterior][fila_anterior].notacion_jugada(columna_siguiente, fila_siguiente)
    self[columna_anterior][fila_anterior].mover(columna_siguiente, fila_siguiente)

    self.mostrar
    if jugador_en_jaque_mate?
      print "Jaque mate, ganaron las #{jugador_siguiente}.\n\n"
      @notacion_jugada << "++"
    elsif jugador_en_ahogado?
      print "No existe una jugadas posible para las #{@jugador_actual}, la partida termina en tablas.\n\n"
    elsif !existen_suficientes_piezas?
      print "No existen suficientes piezas para generar un jaque mate, la partida termina en tablas.\n\n"
    elsif jugador_en_jaque?
      @notacion_jugada << "+"
    end
    @historial << @notacion_jugada

    @notacion_jugada
  end

  def existen_suficientes_piezas?
    values.any? do |columna_hash|
      columna_hash.values.compact.any? do |pieza|
        !pieza.rey?
      end
    end
  end

  def puede_ser_atacado?(columna, fila, jugador = @jugador_actual)
    values.any? do |columna_hash|
      columna_hash.values.compact.any? do |pieza|
        pieza.color != jugador and pieza.puede_atacar?(columna, fila)
      end
    end
  end

  def piezas_que_pueden_moverse_a(columna, fila)
    values.flat_map do |columna_hash|
      columna_hash.values.compact.select do |pieza|
        pieza.puede_moverse?(columna, fila)
      end
    end
  end

  def existe_jugada_posible?(jugador = @jugador_actual)
    values.any? do |columna_hash|
      columna_hash.values.compact.any? do |pieza|
        pieza.color == jugador and pieza.existe_jugada_posible?
      end
    end
  end

  def jugador_en_jaque?(jugador = @jugador_actual)
    values.any? do |columna_hash|
      columna_hash.values.compact.any? do |pieza|
        pieza.rey?(jugador) and pieza.en_jaque?
      end
    end
  end

  def jugador_en_jaque_mate?(jugador = @jugador_actual)
    !existe_jugada_posible?(jugador) and jugador_en_jaque?(jugador)
  end

  def jugador_en_ahogado?(jugador = @jugador_actual)
    !existe_jugada_posible?(jugador) and !jugador_en_jaque?(jugador)
  end

  def jugador_siguiente(jugador = @jugador_actual)
    jugador == BLANCAS ? NEGRAS : BLANCAS
  end

  def jugadas_posibles(columna, fila)
    self[columna][fila].nil? ? [] : self[columna][fila].jugadas_posibles
  end

  def se_puede_jugar?
    !jugador_en_jaque_mate? and !jugador_en_ahogado? and existen_suficientes_piezas?
  end
end
