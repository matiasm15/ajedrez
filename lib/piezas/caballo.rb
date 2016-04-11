module Ajedrez
  ##
  # Clase para la pieza del caballo.
  class Caballo < Pieza
    ##
    # @see MovilLineal#_puede_capturar?
    def _puede_capturar?(columna, fila)
      ((@columna - columna).abs == 2 and (@fila - fila).abs == 1) or
        ((@columna - columna).abs == 1 and (@fila - fila).abs == 2)
    end
  end
end
