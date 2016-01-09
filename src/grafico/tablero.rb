class Tablero < Hash
  attr_accessor :x, :y, :width, :height

  def self.crear(x = 60, y = 60, width = 60, height = 60)
    nuevo_tablero = self.new

    nuevo_tablero.x = x
    nuevo_tablero.y = y
    nuevo_tablero.width = width
    nuevo_tablero.height = height

    nuevo_tablero.limpiar
  end

  def draw(window, columna_focus, fila_focus)
    (1..8).each do |columna|
      (1..8).each do |fila|
        x_1 = @width * (columna - 1) + @x
        x_2 = @width * columna + @x
        y_1 = @height * (fila - 1) + @y
        y_2 = @height * fila + @y

        color = if columna == columna_focus and fila == fila_focus
                  Color::BLUE
                else
                  (columna + fila).even? ? Color::WHITE : Color::RED
                end

        window.draw_quad(x_1, y_1, color, x_2, y_1, color, x_2, y_2, color, x_1, y_2, color)

        window.draw_pieza(self[columna][fila], x_1, y_1) if !self[columna][fila].nil?
      end
    end

    if (1..8).include?(columna_focus) and (1..8).include?(fila_focus)
      self[columna_focus][fila_focus].jugadas_posibles.each do |columna, fila|
        x_1 = @width * (columna - 1) + @x
        x_2 = @width * columna + @x
        y_1 = @height * (fila - 1) + @y
        y_2 = @height * fila + @y

        window.draw_quad(x_1, y_1, Color::CYAN, x_2, y_1, Color::CYAN, x_2, y_2, Color::CYAN, x_1, y_2, Color::CYAN)

        window.draw_pieza(self[columna][fila], x_1, y_1) if !self[columna][fila].nil?
      end
    end
  end
end
