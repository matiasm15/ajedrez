class Tablero < Hash
  attr_reader :jugador, :historial, :notacion
  attr_accessor :captura_al_paso, :test

  def initialize
    @historial = Historial.new
    @jugador = BLANCAS
    @captura_al_paso = 0
    @test = false

    self.limpiar
  end

  def test?
    @test
  end

  def deep_clone
    Marshal.load(Marshal.dump(self))
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

  def mover(columna_anterior, fila_anterior, columna_siguiente, fila_siguiente)
    unless se_puede_jugar?
      raise MovimientoInvalido, "Movimiento no valido: la partida ha terminado."
    end

    if [columna_anterior, fila_anterior, columna_siguiente, fila_siguiente].any? { |limite| !(1..8).include?(limite) }
      raise MovimientoInvalido, "Movimiento no valido: coordenadas fuera de los limites."
    end

    if self[columna_anterior][fila_anterior].nil?
      raise MovimientoInvalido, "Movimiento no valido: pieza inexistente."
    end

    if self[columna_anterior][fila_anterior].color != @jugador
      raise MovimientoInvalido, "Movimiento no valido: turno incorrecto."
    end

    unless self[columna_anterior][fila_anterior].puede_moverse?(columna_siguiente, fila_siguiente)
      raise MovimientoInvalido, "Movimiento no valido."
    end

    @jugador = jugador_siguiente
    @notacion = self[columna_anterior][fila_anterior].notacion(columna_siguiente, fila_siguiente)
    self[columna_anterior][fila_anterior].mover(columna_siguiente, fila_siguiente)

    if jaque_mate?
      @notacion << "++"
    elsif !ahogado? and suficientes_piezas? and jaque?
      @notacion << "+"
    end
    @historial << @notacion

    self
  end

  def suficientes_piezas?
    values.any? do |columna_hash|
      columna_hash.values.compact.any? do |pieza|
        !pieza.rey?
      end
    end
  end

  def puede_ser_atacado?(columna, fila, jugador = @jugador)
    values.any? do |columna_hash|
      columna_hash.values.compact.any? do |pieza|
        pieza.color != jugador and pieza.puede_atacar?(columna, fila)
      end
    end
  end

  def movibles_a(columna, fila)
    values.flat_map do |columna_hash|
      columna_hash.values.compact.select do |pieza|
        pieza.puede_moverse?(columna, fila)
      end
    end
  end

  def existe_jugada_posible?(jugador = @jugador)
    values.any? do |columna_hash|
      columna_hash.values.compact.any? do |pieza|
        pieza.color == jugador and pieza.existe_jugada_posible?
      end
    end
  end

  def jaque?(jugador = @jugador)
    values.any? do |columna_hash|
      columna_hash.values.compact.any? do |pieza|
        pieza.rey?(jugador) and pieza.jaque?
      end
    end
  end

  def jaque_mate?(jugador = @jugador)
    !existe_jugada_posible?(jugador) and jaque?(jugador)
  end

  def ahogado?(jugador = @jugador)
    !existe_jugada_posible?(jugador) and !jaque?(jugador)
  end

  def jugador_siguiente(jugador = @jugador)
    jugador == BLANCAS ? NEGRAS : BLANCAS
  end

  def jugadas_posibles(columna, fila)
    self[columna][fila].nil? ? [] : self[columna][fila].jugadas_posibles
  end

  def se_puede_jugar?
    !jaque_mate? and !ahogado? and suficientes_piezas?
  end
end
