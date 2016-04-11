module Ajedrez
  ##
  # Modulo de las piezas blancas.
  module Blancas
    ##
    # Devuelve la fila donde quedaria la pieza si se moviera <em>n</em> posiciones desde <em>fila</em>.
    def self.avanzar(fila, n = 1)
      fila + n
    end

    ##
    # Devuelve la fila donde se encuentra el rey cuando la partida comienza.
    def self.fila_inicial
      1
    end

    ##
    # Devuelve un string con el nombre del color del jugador.
    def self.to_s
      "blancas"
    end
  end

  ##
  # Modulo de las piezas negras.
  module Negras
    ##
    # @see Blancas.avanzar
    def self.avanzar(fila, n = 1)
      fila - n
    end

    ##
    # @see Blancas.fila_inicial
    def self.fila_inicial
      8
    end

    ##
    # @see Blancas.to_s
    def self.to_s
      "negras"
    end
  end
end
