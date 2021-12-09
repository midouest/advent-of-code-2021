defmodule Day09Test do
  use ExUnit.Case

  import Advent.Day09

  @example [
    "2199943210",
    "3987894921",
    "9856789892",
    "8767896789",
    "9899965678"
  ]

  test "part 1 example" do
    assert risk_level(@example) == 15
  end
end
