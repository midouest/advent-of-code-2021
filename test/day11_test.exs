defmodule Day11Test do
  use ExUnit.Case

  import Advent.Day11

  @example [
    "5483143223",
    "2745854711",
    "5264556173",
    "6141336146",
    "6357385478",
    "4167524645",
    "2176841721",
    "6882881134",
    "4846848554",
    "5283751526"
  ]

  test "part 1 example" do
    assert total_flashes(@example) == 1656
  end
end
