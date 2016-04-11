module Ajedrez
  ##
  # Clase para la pieza del peon.
  class Peon < Pieza
    ##
    # Devuelve la notacion algebraica del movimiento de la pieza a la posicion dada. No incluye la parte de la
    # notacion que describe a la coronacion en caso que lo hubiera.
    def notacion(columna, fila)
      if puede_capturar_al_paso?(columna, fila)
        "#{@columna.to_lttr}x#{columna.to_lttr}#{fila}e.p."
      elsif puede_capturar?(columna, fila)
        "#{@columna.to_lttr}x#{columna.to_lttr}#{fila}"
      else
        "#{columna.to_lttr}#{fila}"
      end
    end

    ##
    # @see Pieza#mover
    def mover(columna, fila)
      @tablero[columna][@fila] = nil if puede_capturar_al_paso?(columna, fila)

      @tablero.captura_al_paso = puede_avanzar_doble?(columna, fila) ? columna : nil
      @tablero[@columna][@fila] = nil
      @columna = columna
      @fila = fila
      @tablero[columna][fila] = (!@tablero.test? and fila == fila_final) ? coronar : self
    end

    ##
    # Devuelve si la pieza puede moverse sin realizar una captura en una posicion dada. Igualmente, el movimiento
    # podria realizar una captura al paso en otra posicion. No comprueba el estado de la posicion destino del
    # movimiento ni si producira que el rey este en jaque.
    def _puede_desplazarse?(columna, fila)
      puede_avanzar_simple?(columna, fila) or puede_avanzar_doble?(columna, fila) or puede_capturar_al_paso?(columna, fila)
    end

    ##
    # Devuelve si la pieza puede capturar una pieza del contrario en una posicion dada. No se tienen en cuenta las
    # capturas al paso. No comprueba el estado de la posicion destino del movimiento ni si producira que el rey este
    # en jaque.
    def _puede_capturar?(columna, fila)
      (@columna - columna).abs == 1 and fila_siguiente == fila
    end

    ##
    # Devuelve si se puede hacer un avance de un escaque a una posicion dada. No comprueba el estado de la posicion
    # destino del movimiento ni si producira que el rey este en jaque.
    def puede_avanzar_simple?(columna, fila)
      fila_siguiente == fila and @columna == columna
    end

    ##
    # Devuelve si se puede hacer un avance de dos escaques a una posicion dada. No comprueba el estado de la posicion
    # destino del movimiento ni si producira que el rey este en jaque.
    def puede_avanzar_doble?(columna, fila)
      fila_inicial == @fila and fila_doble_avance == fila and @tablero[columna][fila_siguiente].nil? and @columna == columna
    end

    ##
    # Devuelve si al mover la pieza a una posicion dada se realizara una captura al paso. No comprueba el estado de
    # la posicion destino del movimiento ni si producira que el rey este en jaque.
    def puede_capturar_al_paso?(columna, fila)
      _puede_capturar?(columna, fila) and @tablero.captura_al_paso == columna and @color.avanzar(fila_inicial, 3) == @fila
    end

    ##
    # Devuelve la fila donde se encontrara el peon luego de avanzar un escaque desde <em>fila</em>.
    def fila_siguiente
      @color.avanzar(@fila)
    end

    ##
    # Devuelve la fila donde se encuentra el peon cuando la partida comienza.
    def fila_inicial
      @color.avanzar(@color.fila_inicial)
    end

    ##
    # Devuelve la segunda fila a la que puede moverse el peon, es decir, aquella donde se encontrara luego de
    # realizar un avance de dos escaques.
    def fila_doble_avance
      @color.avanzar(@color.fila_inicial, 3)
    end

    ##
    # Devuelve la ultima fila a la que puede moverse el peon, es decir, aquella donde corona.
    def fila_final
      @color.avanzar(@color.fila_inicial, 7)
    end

    ##
    # Devuelve la nueva pieza que reemplazara al peon al producirse la coronacion. El tipo de la pieza sera el
    # devuelto por {Peon#_coronar}.
    # @raise [MovimientoInvalido] Si el retorno de {Peon#_coronar} no corresponde con ningun tipo de pieza valida.
    def coronar
      case _coronar
        when "D"
          @tablero.notacion << "=D"
          Dama.new(@color, @columna, @fila, @tablero)
        when "A"
          @tablero.notacion << "=A"
          Alfil.new(@color, @columna, @fila, @tablero)
        when "C"
          @tablero.notacion << "=C"
          Caballo.new(@color, @columna, @fila, @tablero)
        when "T"
          @tablero.notacion << "=T"
          Torre.new(@color, @columna, @fila, @tablero)
        else
          raise MovimientoInvalido, "la pieza elegida para coronar no es valida"
      end
    end

    # @!group Methods not implemented

    ##
    # Se debe implementar el mecanismo para elegir la pieza a la que va a coronar el peon.
    # @return [String] Debe devolver "D", "A", "C" o "T" para coronar como una {Dama}, un {Alfil}, un {Caballo} o
    #   una {Torre} respectivamente.
    # @raise [NotImplementedError] Si el metodo no ha sido implementado aun.
    def _coronar
      raise NotImplementedError, "se debe implementar el metodo para coronar el peon"
    end

    # @!endgroup
  end
end
