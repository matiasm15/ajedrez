require_relative 'exception'
require_relative 'jugadores'
require_relative 'tablero'

require_relative './piezas/pieza'
require_relative './piezas/movil'

require_relative './piezas/alfil'
require_relative './piezas/caballo'
require_relative './piezas/dama'
require_relative './piezas/peon'
require_relative './piezas/rey'
require_relative './piezas/torre'

##
# Clase de los numeros enteros en Ruby.
class Fixnum
  ##
  # Devuelve la letra que identifica a una columna dada.
  def to_lttr
    (self + 96).chr
  end
end

##
# Namespace para todas las clases de la libreria.
module Ajedrez; end
