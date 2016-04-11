module Ajedrez
  ##
  # Clase para la pieza del rey.
  class Rey < Pieza
    ##
    # @see Pieza#notacion
    def notacion(columna, fila)
      if puede_enrocar_corto?(columna, fila)
        "0+0"
      elsif puede_enrocar_largo?(columna, fila)
        "0+0+0"
      else
        super
      end
    end

    ##
    # @see Pieza#mover
    def mover(columna, fila)
      # Para evitar un ciclo infinito.
      unless @tablero.test?
        if puede_enrocar_largo?(columna, fila)
          @tablero[1][fila].mover(4, fila)
        elsif puede_enrocar_corto?(columna, fila)
          @tablero[8][fila].mover(6, fila)
        end
      end

      super
    end

    ##
    # Devuelve si el rey puede realizar un enroque a una posicion dada. No comprueba si el movimiento producira que
    # el rey este en jaque.
    def puede_enrocar?(columna, fila)
      puede_enrocar_largo?(columna, fila) or puede_enrocar_corto?(columna, fila)
    end

    ##
    # Devuelve si el rey puede realizar un enroque largo a una posicion dada. No comprueba si el movimiento
    # producira que el rey este en jaque.
    def puede_enrocar_largo?(columna, fila)
      fila == @fila and columna == 3 and !se_movio? and !jaque? and !jaque?(4, fila) and
        !@tablero[1][fila].nil? and @tablero[1][fila].puede_enrocar?(@columna, @fila)
    end

    ##
    # Devuelve si el rey puede realizar un enroque corto a una posicion dada. No comprueba si el movimiento
    # producira que el rey este en jaque.
    def puede_enrocar_corto?(columna, fila)
      fila == @fila and columna == 7 and !se_movio? and !jaque? and !jaque?(6, fila) and
        !@tablero[8][fila].nil? and @tablero[8][fila].puede_enrocar?(@columna, @fila)
    end

    ##
    # Devuelve si el rey esta en jaque.
    def cumple_condicion_jaque?
      @tablero.values.any? do |columna_hash|
        columna_hash.values.compact.any? do |pieza|
          pieza.color != @color and pieza._puede_capturar?(@columna, @fila)
        end
      end
    end

    ##
    # @see Pieza#_puede_desplazarse?
    def _puede_desplazarse?(columna, fila)
      _puede_capturar?(columna, fila) or puede_enrocar?(columna, fila)
    end

    ##
    # @see MovilLineal#_puede_capturar?
    def _puede_capturar?(columna, fila)
      (@columna - columna).abs <= 1 and (@fila - fila).abs <= 1
    end

    ##
    # @see Pieza#rey?
    def rey?(color = @color)
      color == @color
    end
  end
end
