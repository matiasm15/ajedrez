module Ajedrez
  ##
  # Clase para la pieza de la dama.
  class Dama < Pieza
    include MovilLineal

    ##
    # Devuelve si la pieza puede capturar una pieza del contrario en una posicion dada realizando un movimiento
    # horizontal o vertical. No comprueba el estado de la posicion destino del movimiento ni si producira que el rey
    # este en jaque.
    alias_method :_puede_capturar_linealmente?, :_puede_capturar?

    include MovilDiagonal

    ##
    # Devuelve si la pieza puede capturar una pieza del contrario en una posicion dada realizando un movimiento
    # diagonal. No comprueba el estado de la posicion destino del movimiento ni si producira que el rey este en
    # jaque.
    alias_method :_puede_capturar_diagonalmente?, :_puede_capturar?

    ##
    # @see MovilLineal#_puede_capturar?
    def _puede_capturar?(columna, fila)
      _puede_capturar_linealmente?(columna, fila) or _puede_capturar_diagonalmente?(columna, fila)
    end
  end
end
