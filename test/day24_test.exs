defmodule Day24Test do
  use ExUnit.Case

  alias Advent.Day24.Solver
  alias Advent.Day24.Program

  @example1 [
    "inp x",
    "mul x -1"
  ]

  @example2 [
    "inp z",
    "inp x",
    "mul z 3",
    "eql z x"
  ]

  @example3 [
    "inp w",
    "add z w",
    "mod z 2",
    "div w 2",
    "add y w",
    "mod y 2",
    "div w 2",
    "add x w",
    "mod x 2",
    "div w 2",
    "mod w 2"
  ]

  test "part 1 example 1" do
    p =
      @example1
      |> Program.parse()
      |> Program.run()

    assert Solver.eval(p.x, %{{:d, 0} => 1}) == -1
    assert Solver.eval(p.x, %{{:d, 0} => -1}) == 1
  end

  test "part 1 example 2" do
    p =
      @example2
      |> Program.parse()
      |> Program.run()

    assert Solver.eval(p.z, %{{:d, 0} => 1, {:d, 1} => 3}) == 1
    assert Solver.eval(p.z, %{{:d, 0} => 1, {:d, 1} => 2}) == 0
  end

  test "part 1 example 3" do
    p =
      @example3
      |> Program.parse()
      |> Program.run()

    assert Solver.eval(p.w, %{{:d, 0} => 8}) == 1
    assert Solver.eval(p.x, %{{:d, 0} => 8}) == 0
    assert Solver.eval(p.y, %{{:d, 0} => 8}) == 0
    assert Solver.eval(p.z, %{{:d, 0} => 8}) == 0
  end
end
