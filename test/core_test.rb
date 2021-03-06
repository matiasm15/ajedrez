require 'simplecov'
SimpleCov.start

require 'minitest/reporters'
require 'minitest/autorun'
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

require_relative '../lib/ajedrez'
include Ajedrez

class TestAjedrez < Minitest::Test
  def setup
    @tablero = Tablero.new
  end

  def test_mate
    Rey.new(Blancas, 2, 1, @tablero)
    Rey.new(Negras, 7, 8, @tablero)
    Alfil.new(Negras, 1, 4, @tablero)
    Caballo.new(Negras, 2, 8, @tablero)
    Torre.new(Blancas, 2, 6, @tablero)
    Peon.new(Negras, 6, 7, @tablero)
    Peon.new(Negras, 7, 7, @tablero)
    Peon.new(Negras, 8, 7, @tablero)

    @tablero.mover(2, 6, 2, 8)                        # b6 a b8

    assert @tablero.jaque?
    assert_equal @tablero.notacion, "Txb8+"

    @tablero.mover(1, 4, 5, 8)                        # a4 a e8
    @tablero.mover(2, 8, 5, 8)                        # e8 a c8

    assert @tablero.jaque_mate?
    assert_equal @tablero.notacion, "Txe8++"
  end

  def test_mate_del_loco
    @tablero.colocar_piezas

    @tablero.mover(6, 2, 6, 3)                        # f2 a f3
    @tablero.mover(5, 7, 5, 5)                        # e7 a e5
    @tablero.mover(7, 2, 7, 4)                        # g2 a g4
    @tablero.mover(4, 8, 8, 4)                        # d8 a h4

    assert @tablero.jaque_mate?

    assert_equal @tablero.historial, [
      "f3",
      "e5",
      "g4",
      "Dh4++"
    ]
  end

  # Defensa Patrov
  def test_captura_al_paso
    @tablero.colocar_piezas

    @tablero.mover(5, 2, 5, 4)                        # e2 a e4
    @tablero.mover(5, 7, 5, 5)                        # e7 a e5
    @tablero.mover(7, 1, 6, 3)                        # g1 a f3
    @tablero.mover(7, 8, 6, 6)                        # g8 a f6
    @tablero.mover(4, 2, 4, 4)                        # d2 a d4
    @tablero.mover(5, 5, 4, 4)                        # e5 a d4
    @tablero.mover(5, 4, 5, 5)                        # e4 a e5
    @tablero.mover(6, 6, 5, 4)                        # f6 a e4
    @tablero.mover(4, 1, 4, 4)                        # d1 a d4
    @tablero.mover(4, 7, 4, 5)                        # d7 a d5
    @tablero.mover(5, 5, 4, 6)                        # e5 a d6

    assert_nil @tablero[4][5]

    assert_equal @tablero.historial, [
      "e4",
      "e5",
      "Cf3",
      "Cf6",
      "d4",
      "exd4",
      "e5",
      "Ce4",
      "Dxd4",
      "d5",
      "exd6e.p."
    ]
  end

  def test_movimiento_ambiguo_1
    Rey.new(Blancas, 2, 1, @tablero)
    Rey.new(Negras, 2, 7, @tablero)
    Dama.new(Blancas, 1, 4, @tablero)
    Dama.new(Blancas, 4, 8, @tablero)
    Dama.new(Blancas, 8, 8, @tablero)
    Peon.new(Negras, 4, 4, @tablero)

    @tablero.mover(1, 4, 4, 4)                        # a4 a d4

    assert_equal @tablero.notacion, "Daxd4"
  end

  def test_movimiento_ambiguo_2
    Rey.new(Blancas, 2, 1, @tablero)
    Rey.new(Negras, 2, 7, @tablero)
    Dama.new(Blancas, 4, 1, @tablero)
    Dama.new(Blancas, 4, 8, @tablero)
    Peon.new(Negras, 4, 4, @tablero)

    @tablero.mover(4, 1, 4, 4)                        # d1 a d4

    assert_equal @tablero.notacion, "D1xd4"
  end

  def test_movimiento_ambiguo_3
    Rey.new(Blancas, 2, 1, @tablero)
    Rey.new(Negras, 2, 7, @tablero)
    Dama.new(Blancas, 4, 1, @tablero)
    Dama.new(Blancas, 4, 8, @tablero)
    Dama.new(Blancas, 8, 8, @tablero)
    Peon.new(Negras, 4, 4, @tablero)

    @tablero.mover(4, 1, 4, 4)                        # d1 a d4

    assert_equal @tablero.notacion, "D1xd4"
  end

  def test_movimiento_ambiguo_4
    Rey.new(Blancas, 2, 1, @tablero)
    Rey.new(Negras, 2, 7, @tablero)
    Caballo.new(Blancas, 3, 2, @tablero)
    Caballo.new(Blancas, 3, 6, @tablero)
    Caballo.new(Blancas, 5, 2, @tablero)
    Caballo.new(Blancas, 5, 6, @tablero)
    Peon.new(Negras, 4, 4, @tablero)

    @tablero.mover(3, 2, 4, 4)                        # c2 a d4

    assert_equal @tablero.notacion, "Cc2xd4"
  end

  def test_enrroque
    Torre.new(Blancas, 1, 1, @tablero)
    Caballo.new(Blancas, 2, 1, @tablero)
    Dama.new(Blancas, 6, 3, @tablero)
    Rey.new(Blancas, 5, 1, @tablero)
    Caballo.new(Blancas, 7, 1, @tablero)
    Torre.new(Blancas, 8, 1, @tablero)
    Torre.new(Negras, 1, 8, @tablero)
    Dama.new(Negras, 4, 8, @tablero)
    Rey.new(Negras, 5, 8, @tablero)
    Torre.new(Negras, 8, 8, @tablero)

    assert_raises(MovimientoInvalido) {               # No puede enrrocar ya que hay una pieza en el medio del camino de la torre.
      @tablero.mover(5, 1, 3, 1)                      # e1 a c1
    }
    assert_raises(MovimientoInvalido) {               # No puede enrrocar ya que hay una pieza en la posicion de destino.
      @tablero.mover(5, 1, 7, 1)                      # e1 a g1
    }

    @tablero.mover(7, 1, 8, 3)                        # g1 a h3

    assert_raises(MovimientoInvalido) {               # No puede enrrocar ya que hay una pieza en el medio de su camino.
      @tablero.mover(5, 8, 3, 8)                      # e8 a c8
    }
    assert_raises(MovimientoInvalido) {               # No puede enrrocar ya que la reina blanca amenaza f8.
      @tablero.mover(5, 8, 7, 8)                      # e8 a g8
    }

    @tablero.mover(8, 8, 8, 7)                        # h8 a h7
    @tablero.mover(6, 3, 5, 3)                        # f3 a e3

    assert_raises(MovimientoInvalido) {               # No puede enrrocar ya que esta en jaque.
      @tablero.mover(5, 8, 7, 8)                      # e8 a g8
    }

    @tablero.mover(4, 8, 5, 7)                        # d8 a e7
    @tablero.mover(5, 1, 7, 1)                        # e1 a g1 (enrroque corto)

    assert_equal @tablero.notacion, "0+0"

    @tablero.mover(8, 7, 8, 8)                        # h7 a h8
    @tablero.mover(2, 1, 1, 3)                        # b1 a a3

    assert_raises(MovimientoInvalido) {               # No puede enrrocar ya que la torre se ha movido.
      @tablero.mover(5, 8, 7, 8)                      # e8 a g8
    }

    @tablero.mover(5, 8, 3, 8)                        # e8 a c8 (enrroque largo)

    assert_equal @tablero.notacion, "0+0+0"
  end

  def test_coronacion
    Peon.send(:define_method, :_coronar) do           # Implemento el método _coronar de Peon.
      "T"
    end

    Rey.new(Blancas, 2, 1, @tablero)
    Rey.new(Negras, 7, 8, @tablero)
    Alfil.new(Negras, 1, 4, @tablero)
    Caballo.new(Negras, 2, 8, @tablero)
    Peon.new(Blancas, 3, 7, @tablero)
    Peon.new(Negras, 6, 7, @tablero)
    Peon.new(Negras, 7, 7, @tablero)
    Peon.new(Negras, 8, 7, @tablero)

    @tablero.mover(3, 7, 2, 8)                        # e8 a b8 (peón corona a torre)

    assert @tablero[2][8].torre?(Blancas)
    assert_equal @tablero.notacion, "cxb8=T+"
  end
end
