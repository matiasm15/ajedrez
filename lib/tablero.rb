module Ajedrez
  ##
  # Clase del tablero de la partida.
  # @raise [KeyError] Si se usa como indice del tablero un numero entero no perteneciente a <em>1..8</em>.
  class Tablero < Hash
    ##
    # @return [Array] Historial de los movimientos de la partida en notacion algebraica.
    attr_reader :historial

    ##
    # @return [String] Notacion algebraica del ultimo movimiento.
    attr_accessor :notacion

    ##
    # @return [Blancas, Negras] Jugador que debe realizar el proximo movimiento.
    attr_accessor :jugador

    ##
    # @return [Fixnum, nil] Columna del peon que realizo el doble avance en el turno anterior. Si no ocurrio un
    # doble avance, su valor es <em>nil</em>.
    attr_accessor :captura_al_paso

    ##
    # @return [Boolean] Define si es un tablero de pruebas.
    attr_writer :test

    ##
    # Crea un tablero vacio.
    def initialize
      @historial = Array.new
      @jugador = Blancas
      @test = false
      @notacion = ""

      self.default_proc = proc { raise KeyError, "coordenadas fuera de los limites del tablero" }
      self.vaciar
    end

    ##
    # Devuelve si es un tablero de pruebas.
    def test?
      @test
    end

    ##
    # Devuelve una copia profunda del tablero y sus piezas.
    def deep_clone
      Tablero.new.tap do |tablero_clon|
        tablero_clon.test = true
        tablero_clon.jugador = @jugador
        tablero_clon.captura_al_paso = @captura_al_paso
        tablero_clon.notacion = @notacion.clone

        @historial.each do |movimiento|
          tablero_clon.historial << movimiento.clone
        end

        piezas.each do |pieza|
          pieza_clon = pieza.clone
          pieza_clon.tablero = tablero_clon
          tablero_clon[pieza.columna][pieza.fila] = pieza_clon
        end
      end
    end

    ##
    # Vacia el tablero y coloca nuevas piezas.
    def colocar_piezas
      self.vaciar.tap do |tablero|
        (1..8).each do |columna|
          Peon.new(Blancas, columna, 2, tablero)
          Peon.new(Negras, columna, 7, tablero)
        end

        Torre.new(Blancas, 1, 1, tablero)
        Caballo.new(Blancas, 2, 1, tablero)
        Alfil.new(Blancas, 3, 1, tablero)
        Dama.new(Blancas, 4, 1, tablero)
        Rey.new(Blancas, 5, 1, tablero)
        Alfil.new(Blancas, 6, 1, tablero)
        Caballo.new(Blancas, 7, 1, tablero)
        Torre.new(Blancas, 8, 1, tablero)
        Torre.new(Negras, 1, 8, tablero)
        Caballo.new(Negras, 2, 8, tablero)
        Alfil.new(Negras, 3, 8, tablero)
        Dama.new(Negras, 4, 8, tablero)
        Rey.new(Negras, 5, 8, tablero)
        Alfil.new(Negras, 6, 8, tablero)
        Caballo.new(Negras, 7, 8, tablero)
        Torre.new(Negras, 8, 8, tablero)
      end
    end

    ##
    # Vacia el tablero.
    def vaciar
      self.tap do |tablero|
        (1..8).each do |columna|
          tablero[columna] = Hash.new { raise KeyError, "coordenadas fuera de los limites del tablero" }

          (1..8).each do |fila|
            tablero[columna][fila] = nil
          end
        end
      end
    end

    ##
    # Mueve la pieza que esta en <em>columna_anterior, fila_anterior</em> a la posicion
    # <em>columna_siguiente, fila_siguiente</em>.
    # @raise [MovimientoInvalido] Si el movimiento no se puede hacer.
    def mover(columna_anterior, fila_anterior, columna_siguiente, fila_siguiente)
      self.tap do |tablero|
        unless se_puede_jugar?
          raise MovimientoInvalido, "la partida ha terminado"
        end

        unless tablero[columna_anterior][fila_anterior]
          raise MovimientoInvalido, "pieza inexistente"
        end

        unless tablero[columna_anterior][fila_anterior].color == @jugador
          raise MovimientoInvalido, "turno incorrecto"
        end

        unless tablero[columna_anterior][fila_anterior].puede_moverse?(columna_siguiente, fila_siguiente)
          raise MovimientoInvalido, "la pieza no puede moverse a la posicion indicada"
        end

        @notacion = tablero[columna_anterior][fila_anterior].notacion(columna_siguiente, fila_siguiente)

        tablero[columna_anterior][fila_anterior].mover(columna_siguiente, fila_siguiente)

        @jugador = jugador_siguiente

        if jaque_mate?
          @notacion << "++"
        elsif !ahogado? and suficientes_piezas? and jaque?
          @notacion << "+"
        end

        @historial << @notacion
      end
    end

    ##
    # Devuelve todas las piezas del tablero.
    def piezas
      values.flat_map { |columna_hash| columna_hash.values.compact }
    end

    ##
    # Devuelve todas las piezas que pueden moverse a una determinada posicion.
    def movibles_a(columna, fila)
      piezas.select { |pieza| pieza.puede_moverse?(columna, fila) }
    end

    ##
    # Devuelve si el tablero tiene suficientes piezas que permitan seguir jugando.
    def suficientes_piezas?
      piezas.any? { |pieza| !pieza.rey? }
    end

    ##
    # Devuelve un determinado jugador puede mover alguna de sus piezas.
    def existe_jugada_posible?(jugador = @jugador)
      piezas.any? { |pieza| pieza.color == jugador and pieza.existe_jugada_posible? }
    end

    ##
    # Devuelve si la partida esta en situacion de jaque para un determinado jugador.
    def jaque?(jugador = @jugador)
      piezas.any? { |pieza| pieza.rey?(jugador) and pieza.cumple_condicion_jaque? }
    end

    ##
    # Devuelve si la partida esta en situacion de jaque mate para un determinado jugador.
    def jaque_mate?(jugador = @jugador)
      !existe_jugada_posible?(jugador) and jaque?(jugador)
    end

    ##
    # Devuelve si la partida esta en situacion de ahogado para un determinado jugador.
    def ahogado?(jugador = @jugador)
      !existe_jugada_posible?(jugador) and !jaque?(jugador)
    end

    ##
    # Devuelve si la partida se puede seguir jugando.
    def se_puede_jugar?
      !jaque_mate? and !ahogado? and suficientes_piezas?
    end

    ##
    # Devuelve el jugador que tenga el siguiente turno.
    def jugador_siguiente(jugador = @jugador)
      jugador == Blancas ? Negras : Blancas
    end

    ##
    # Devuelve un array con todas las posiciones a las cuales se puede mover la pieza que se encuentra en una
    # posicion dada. Si no existe una pieza en esa posicion se devuelve un array vacio.
    def jugadas_posibles(columna, fila)
      self[columna][fila] ? self[columna][fila].jugadas_posibles : Array.new
    end
  end
end
