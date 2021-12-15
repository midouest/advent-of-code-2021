defmodule Day15Test do
  use ExUnit.Case

  import Advent.Day15

  @example [
    "1163751742",
    "1381373672",
    "2136511328",
    "3694931569",
    "7463417111",
    "1319128137",
    "1359912421",
    "3125421639",
    "1293138521",
    "2311944581"
  ]

  test "part 1 example" do
    assert lowest_risk_path(@example) == 40
  end

  test "part 2 example" do
    assert lowest_risk_path(@example, 5) == 315
  end
end
