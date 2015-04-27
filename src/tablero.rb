class Tablero < Hash
  attr_reader :jugador_actual, :historial, :notacion_jugada
  attr_accessor :captura_al_paso, :en_pruebas

  def initialize
    self.limpiar

    @historial = Historial.new
    @jugador_actual = Blanca
    @captura_al_paso = 0
    @en_pruebas = false
  end

  def en_pruebas?
    @en_pruebas
  end

  def iniciar
    colocar_piezas.mostrar
  end

  def colocar_piezas
    self.limpiar

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

  def limpiar
    for columna in 1..8
      self[columna] = Hash.new
      for fila in 1..8
        self[columna][fila] = nil
      end
    end
  end

  def mostrar
    print "\n  a b c d e f g h\n"

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

  def mover(columna_anterior, fila_anterior, columna_siguiente, fila_siguiente)
    if jugador_en_jaque_mate? or jugador_en_ahogado? or !existen_suficientes_piezas?
      print "La partida ha terminado. Escriba reiniciar para jugar otra.\n\n"
      return
    end
    
    if [columna_anterior, fila_anterior, columna_siguiente, fila_siguiente].any? { |limite| !(1..8).include?(limite) }
      print "Movimiento no valido: coordenadas fuera de los limites.#{columna_anterior}#{fila_anterior}#{columna_siguiente}#{fila_siguiente}\n\n"
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
      print "Jaque mate, ganaron las #{jugador_siguiente.to_s}.\n\n"
      @notacion_jugada << "++"
    elsif jugador_en_ahogado?
      print "No existe una jugadas posible para las #{@jugador_actual.to_s}, la partida termina en tablas.\n\n"
    elsif !existen_suficientes_piezas?
      print "No existen suficientes piezas para generar un jaque mate, la partida termina en tablas.\n\n"
    elsif jugador_en_jaque?
      @notacion_jugada << "+"
    end
    @historial << @notacion_jugada

    @notacion_jugada
  end

  def existen_suficientes_piezas?
    values.any? { |columna_hash|
      columna_hash.values.compact.any? { |pieza|
        !pieza.rey?
      }
    }
  end

  def puede_ser_atacado?(columna, fila, jugador = @jugador_actual)
    values.any? { |columna_hash|
      columna_hash.values.compact.any? { |pieza|
        pieza.color != jugador and pieza.puede_atacar?(columna, fila)
      }
    }
  end

  def piezas_que_pueden_moverse_a(columna, fila)
    values.collect { |columna_hash|
      columna_hash.values.compact.select { |pieza|
        pieza.puede_moverse?(columna, fila)
      }
    }.flatten
  end

  def existe_jugada_posible?(jugador = @jugador_actual)
    values.any? { |columna_hash|
      columna_hash.values.compact.any? { |pieza|
        pieza.color == jugador and pieza.existe_jugada_posible?
      }
    }
  end

  def jugador_en_jaque?(jugador = @jugador_actual)
    values.any? { |columna_hash|
      columna_hash.values.compact.any? { |pieza|
        pieza.rey?(jugador) and pieza.en_jaque?
      }
    }
  end

  def jugador_en_jaque_mate?(jugador = @jugador_actual)
    !existe_jugada_posible?(jugador) and jugador_en_jaque?(jugador)
  end

  def jugador_en_ahogado?(jugador = @jugador_actual)
    !existe_jugada_posible?(jugador) and !jugador_en_jaque?(jugador)
  end

  def jugador_siguiente(jugador = @jugador_actual)
    {Blanca => Negra, Negra => Blanca}[jugador]
  end

  def jugadas_posibles(columna, fila)
    !self[columna][fila].nil? ? self[columna][fila].jugadas_posibles : []
  end
end
