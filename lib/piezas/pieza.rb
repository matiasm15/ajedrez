module Ajedrez
  ##
  # @abstract Superclase de todas las piezas del tablero.
  class Pieza
    ##
    # @return [Tablero] Tablero al que pertenece la pieza.
    attr_writer :tablero

    ##
    # @return [Blancas, Negras] Jugador que posee la pieza.
    attr_reader :color

    ##
    # @return [Fixnum] Columna donde se encuentra la pieza.
    attr_reader :columna

    ##
    # @return [Fixnum] Fila donde se encuentra la pieza.
    attr_reader :fila

    ##
    # Crea una pieza dado el jugador al que pertenece, su posicion y el tablero donde se encuentra.
    def initialize(color, columna, fila, tablero)
      @se_movio = false
      @color = color
      @columna = columna
      @fila = fila
      @tablero = tablero
      @tablero[@columna][@fila] = self
    end

    ##
    # Devuelve si la pieza se movio durante la partida. Las piezas recien coronadas no se consideran como movidas.
    def se_movio?
      @se_movio
    end

    ##
    # Devuelve la inicial del tipo de pieza.
    def inicial
      self.class.name.gsub(/#{Module.nesting.last}::/, '').chr
    end

    ##
    # Devuelve la notacion algebraica del movimiento de la pieza a la posicion dada.
    def notacion(columna, fila)
      ambiguedades = @tablero.movibles_a(columna, fila).select do |pieza|
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

      notacion << "x" if @tablero[columna][fila]
      notacion << "#{columna.to_lttr}#{fila}"
    end

    ##
    # Mueve la pieza a la posicion dada. No comprueba que el movimiento sea valido.
    def mover(columna, fila)
      @tablero[@columna][@fila] = nil
      @columna = columna
      @fila = fila
      @se_movio = true
      @tablero.captura_al_paso = nil
      @tablero[@columna][@fila] = self
    end

    ##
    # Devuelve si la pieza puede moverse a alguna posicion.
    def existe_jugada_posible?
      !jugadas_posibles.empty?
    end

    ##
    # Devuelve las posiciones a las que la pieza puede moverse.
    def jugadas_posibles
      Array.new.tap do |jugadas_posibles|
        (1..8).each do |columna|
          (1..8).each do |fila|
            jugadas_posibles << [columna, fila] if puede_moverse?(columna, fila)
          end
        end
      end
    end

    ##
    # Devuelve si el rey estara en jaque en el caso de mover la pieza a una posicion dada.
    def jaque?(columna = @columna, fila = @fila)
      @tablero.deep_clone[@columna][@fila].mover(columna, fila).cumple_condicion_jaque?
    end

    ##
    # Devuelve si la pieza cumple las condiciones necesarias para que el rey este en jaque.
    def cumple_condicion_jaque?
      @tablero.jaque?(@color)
    end

    ##
    # Devuelve si la pieza puede moverse a una posicion dada.
    def puede_moverse?(columna, fila)
      puede_desplazarse?(columna, fila) or puede_capturar?(columna, fila)
    end

    ##
    # Devuelve si la pieza puede moverse sin realizar una captura en una posicion dada.
    def puede_desplazarse?(columna, fila)
      @tablero[columna][fila].nil? and _puede_desplazarse?(columna, fila) and !jaque?(columna, fila)
    end

    ##
    # Devuelve si la pieza puede capturar una pieza del contrario en una posicion dada.
    def puede_capturar?(columna, fila)
      !@tablero[columna][fila].nil? and @tablero[columna][fila].color != @color and
        _puede_capturar?(columna, fila) and !jaque?(columna, fila)
    end

    ##
    # Devuelve si la pieza puede moverse sin realizar una captura en una posicion dada. No comprueba el estado de
    # la posicion destino del movimiento ni si producira que el rey este en jaque.
    def _puede_desplazarse?(columna, fila)
      _puede_capturar?(columna, fila)
    end

    ##
    # Devuelve si la pieza puede realizar un enroque a una posicion dada. No comprueba si el movimiento producira
    # que el rey este en jaque.
    def puede_enrocar?(columna, fila)
      false
    end

    ##
    # Devuelve si la pieza es un rey de un determinado jugador.
    def rey?(color = @color)
      false
    end

    ##
    # Devuelve si la pieza es una torre de un determinado jugador.
    def torre?(color = @color)
      false
    end
  end
end
