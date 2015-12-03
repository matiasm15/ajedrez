require_relative 'historial'
require_relative 'tablero'
require_relative 'pieza'
require_relative 'exceptions'

# Constantes de los dos colores de piezas.
BLANCAS = :blancas
NEGRAS = :negras

# Utilizadas para generar la notación del movimiento.
class Fixnum
  def to_lttr
    (self + 96).chr
  end
end

class String
  def to_num
    ord - 96
  end
end
