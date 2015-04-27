require 'minitest/reporters'
require 'minitest/autorun'
require_relative '../src/ajedrez'
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

class TestAjedrez < Minitest::Test
  def setup
    $tablero = Tablero.new
  end

  def test_mate_del_loco
    $tablero.iniciar

    $tablero.mover(6, 2, 6, 3)
    $tablero.mover(5, 7, 5, 5)
    $tablero.mover(7, 2, 7, 4)
    $tablero.mover(4, 8, 8, 4)
    assert $tablero.jugador_en_jaque_mate?
    $tablero.historial.mostrar
  end

  # Defensa Patrov
  def test_captura_al_paso
    $tablero.iniciar

    $tablero.mover(5, 2, 5, 4)
    $tablero.mover(5, 7, 5, 5)
    $tablero.mover(7, 1, 6, 3)
    $tablero.mover(7, 8, 6, 6)
    $tablero.mover(4, 2, 4, 4)
    $tablero.mover(5, 5, 4, 4)
    $tablero.mover(5, 4, 5, 5)
    $tablero.mover(6, 6, 5, 4)
    $tablero.mover(4, 1, 4, 4)
    $tablero.mover(4, 7, 4, 5)

    assert_equal $tablero.mover(5, 5, 4, 6), "exd6e.p."
    $tablero.historial.mostrar
  end

  def test_movimiento_ambiguo_1
    Rey.new(Blanca, 2, 1)
    Rey.new(Negra, 2, 7)
    Dama.new(Blanca, 1, 4)
    Dama.new(Blanca, 4, 8)
    Dama.new(Blanca, 8, 8)
    PeonNegro.new(4, 4)

    $tablero.mostrar
    assert_equal $tablero.mover(1, 4, 4, 4), "Daxd4"
    $tablero.historial.mostrar
  end

  def test_movimiento_ambiguo_2
    Rey.new(Blanca, 2, 1)
    Rey.new(Negra, 2, 7)
    Dama.new(Blanca, 4, 1)
    Dama.new(Blanca, 4, 8)
    PeonNegro.new(4, 4)

    $tablero.mostrar
    assert_equal $tablero.mover(4, 1, 4, 4), "D1xd4"
    $tablero.historial.mostrar
  end

  def test_movimiento_ambiguo_3
    Rey.new(Blanca, 2, 1)
    Rey.new(Negra, 2, 7)
    Dama.new(Blanca, 4, 1)
    Dama.new(Blanca, 4, 8)
    Dama.new(Blanca, 8, 8)
    PeonNegro.new(4, 4)

    $tablero.mostrar
    assert_equal $tablero.mover(4, 1, 4, 4), "D1xd4"
    $tablero.historial.mostrar
  end

  def test_movimiento_ambiguo_4
    Rey.new(Blanca, 2, 1)
    Rey.new(Negra, 2, 7)
    Caballo.new(Blanca, 3, 2)
    Caballo.new(Blanca, 3, 6)
    Caballo.new(Blanca, 5, 2)
    Caballo.new(Blanca, 5, 6)
    PeonNegro.new(4, 4)

    $tablero.mostrar
    assert_equal $tablero.mover(3, 2, 4, 4), "Cc2xd4"
    $tablero.historial.mostrar
  end

  def test_enrroque
    Torre.new(Blanca, 1, 1)
    Caballo.new(Blanca, 2, 1)
    Dama.new(Blanca, 6, 3)
    Rey.new(Blanca, 5, 1)
    Caballo.new(Blanca, 7, 1)
    Torre.new(Blanca, 8, 1)
    Torre.new(Negra, 1, 8)
    Dama.new(Negra, 4, 8)
    Rey.new(Negra, 5, 8)
    Torre.new(Negra, 8, 8)

    $tablero.historial.mostrar
    assert_nil $tablero.mover(5, 1, 3, 1)             # No puede enrrocar ya que hay una pieza en el medio del camino de la torre.
    assert_nil $tablero.mover(5, 1, 7, 1)             # No puede enrrocar ya que hay una pieza en la posicion de destino.
    $tablero.mover(7, 1, 8, 3)
    assert_nil $tablero.mover(5, 8, 3, 8)             # No puede enrrocar ya que hay una pieza en el medio de su camino.
    assert_nil $tablero.mover(5, 8, 7, 8)             # No puede enrrocar ya que la reina blanca amenaza F8.
    $tablero.mover(8, 8, 8, 7)
    $tablero.mover(6, 3, 5, 3)
    assert_nil $tablero.mover(5, 8, 7, 8)             # No puede enrrocar ya que esta en jaque.
    $tablero.mover(4, 8, 5, 7)
    assert_equal $tablero.mover(5, 1, 7, 1), "0+0"    # Enrroque corto.
    $tablero.mover(8, 7, 8, 8)
    $tablero.mover(2, 1, 1, 3)
    assert_nil $tablero.mover(5, 8, 7, 8)             # No puede enrrocar ya que la torre se ha movido.
    assert_equal $tablero.mover(5, 8, 3, 8), "0+0+0"  # Enrroque largo.
  end
end
