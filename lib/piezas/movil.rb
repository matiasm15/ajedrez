module Ajedrez
  ##
  # Modulo de las piezas que realizan sus movimientos de forma horizontal, vertical o diagonal.
  module Movil
    ##
    # Devuelve si todas los elementos interiores de un rango formado por <em>pos_inicial</em> y <em>pos_final</em>
    # cumplen una determinada condicion.
    def camino_libre?(pos_inicial, pos_final, &block)
      (([pos_inicial, pos_final].min.succ)..([pos_inicial, pos_final].max.pred)).all? do |i|
        block.call(i)
      end
    end
  end

  ##
  # Modulo de las piezas que realizan sus movimientos de forma horizontal y vertical.
  module MovilLineal
    include Movil

    ##
    # Devuelve si la pieza puede capturar una pieza del contrario en una posicion dada. No comprueba el estado de la
    # posicion destino del movimiento ni si producira que el rey este en jaque.
    def _puede_capturar?(columna, fila)
      (@fila == fila and camino_horizontal_libre?(columna)) or (@columna == columna and camino_vertical_libre?(fila))
    end

    ##
    # Devuelve si estan libres todas las posiciones de la fila desde donde se encuentra la pieza hasta
    # <em>columna</em>, sin incluirla.
    def camino_horizontal_libre?(columna)
      camino_libre?(columna, @columna) { |i| @tablero[i][@fila].nil? }
    end

    ##
    # Devuelve si estan libres todas las posiciones de la columna desde donde se encuentra la pieza hasta
    # <em>fila</em> (sin incluirla).
    def camino_vertical_libre?(fila)
      camino_libre?(fila, @fila) { |i| @tablero[@columna][i].nil? }
    end
  end

  ##
  # Modulo de las piezas que realizan sus movimientos de forma diagonal.
  module MovilDiagonal
    include Movil

    ##
    # @see MovilLineal#_puede_capturar?
    def _puede_capturar?(columna, fila)
      (@fila - fila).abs == (@columna - columna).abs and camino_diagonal_libre?(columna, fila)
    end

    ##
    # Devuelve si estan libres todas las posiciones de la diagonal desde donde se encuentra la pieza hasta la
    # posicion definida por <em>columna, fila</em> (sin incluirla).
    def camino_diagonal_libre?(columna, fila)
      camino_libre?(columna, @columna) do |i|
        j = if (@columna > columna and @fila < fila) or (@columna < columna and @fila > fila)
              [fila, @fila].max + [columna, @columna].min - i
            else
              [fila, @fila].min - [columna, @columna].min + i
            end

        @tablero[i][j].nil?
      end
    end
  end
end
