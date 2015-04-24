require 'minitest/reporters'
require 'minitest/autorun'
require_relative '../src/ajedrez'
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

class TestAjedrez < Minitest::Test
  def setup
    $historial = Historial.new
    $captura_al_paso = 0
    $jugador_actual = Blanca

    $tablero = Tablero.new
    for i in 1..8
      for j in 1..8
        $tablero[i][j] = nil
      end
    end   
  end

  def test_mate_del_loco
    $tablero.colocar_piezas.mostrar

    mover(F2, F3)
    mover(E7, E5)
    mover(G2, G4)
    mover(D8, H4)
    assert jugador_en_jaque_mate?
    historial
  end

  # Defensa Patrov
  def test_captura_al_paso
    $tablero.colocar_piezas.mostrar

    mover(E2, E4)
    mover(E7, E5)
    mover(G1, F3)
    mover(G8, F6)
    mover(D2, D4)
    mover(E5, D4)
    mover(E4, E5)
    mover(F6, E4)
    mover(D1, D4)
    mover(D7, D5)

    assert_equal(mover(E5, D6), "exd6e.p.")
    historial
  end

  def test_movimiento_ambiguo_1
    Rey.new(Blanca, 2, 1)
    Rey.new(Negra, 2, 7)
    Dama.new(Blanca, 1, 4)
    Dama.new(Blanca, 4, 8)
    Dama.new(Blanca, 8, 8)
    PeonNegro.new(4, 4)

    tablero
    assert_equal(mover(A4, D4), "Daxd4")
    historial
  end

  def test_movimiento_ambiguo_2
    Rey.new(Blanca, 2, 1)
    Rey.new(Negra, 2, 7)
    Dama.new(Blanca, 4, 1)
    Dama.new(Blanca, 4, 8)
    PeonNegro.new(4, 4)

    tablero
    assert_equal(mover(D1, D4), "D1xd4")
    historial
  end

  def test_movimiento_ambiguo_3
    Rey.new(Blanca, 2, 1)
    Rey.new(Negra, 2, 7)
    Dama.new(Blanca, 4, 1)
    Dama.new(Blanca, 4, 8)
    Dama.new(Blanca, 8, 8)
    PeonNegro.new(4, 4)

    tablero
    assert_equal(mover(D1, D4), "D1xd4")
    historial
  end

  def test_movimiento_ambiguo_4
    Rey.new(Blanca, 2, 1)
    Rey.new(Negra, 2, 7)
    Caballo.new(Blanca, 3, 2)
    Caballo.new(Blanca, 3, 6)
    Caballo.new(Blanca, 5, 2)
    Caballo.new(Blanca, 5, 6)
    PeonNegro.new(4, 4)

    tablero
    assert_equal(mover(C2, D4), "Cc2xd4")
    historial
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

    tablero
    assert_equal(mover(E1, C1), nil)      # No puede enrrocar ya que hay una pieza en el medio del camino de la torre.
    assert_equal(mover(E1, G1), nil)      # No puede enrrocar ya que hay una pieza en la posicion de destino.
    mover(G1, H3)
    assert_equal(mover(E8, C8), nil)      # No puede enrrocar ya que hay una pieza en el medio de su camino.
    assert_equal(mover(E8, G8), nil)      # No puede enrrocar ya que la reina blanca amenaza F8.
    mover(H8, H7)
    mover(F3, E3)
    assert_equal(mover(E8, G8), nil)      # No puede enrrocar ya que esta en jaque.
    mover(D8, E7)
    assert_equal(mover(E1, G1), "0+0")    # Enrroque corto.
    mover(H7, H8)
    mover(B1, A3)
    assert_equal(mover(E8, G8), nil)      # No puede enrrocar ya que la torre se ha movido.
    assert_equal(mover(E8, C8), "0+0+0")  # Enrroque largo.
  end
end
