module Ajedrez
  ##
  # Clase para la pieza de la torre.
  class Torre < Pieza
    include MovilLineal

    ##
    # @see Pieza#torre?
    def torre?(color = @color)
      color == @color
    end

    ##
    # Devuelve si la torre puede enrrocar dada la posicion de un rey.
    def puede_enrocar?(columna, fila)
      @tablero[columna][fila].color == @color and !se_movio? and camino_horizontal_libre?(columna)
    end
  end
end
