defmodule Day02Test do
  use ExUnit.Case

  import Advent.Day02

  @example [
    "forward 5",
    "down 5",
    "forward 8",
    "up 3",
    "down 8",
    "forward 2"
  ]

  test "part1 example" do
    assert pilot(@example, &part1_exec/2) == 150
  end

  test "part2 example" do
    assert pilot(@example, &part2_exec/2) == 900
  end
end
