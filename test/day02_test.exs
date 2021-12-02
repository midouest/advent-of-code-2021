defmodule Day02Test do
  use ExUnit.Case

  import Advent.Day02
  alias Advent.Day02.Part1
  alias Advent.Day02.Part2

  @example [
    "forward 5",
    "down 5",
    "forward 8",
    "up 3",
    "down 8",
    "forward 2"
  ]

  test "part1 example" do
    assert pilot(@example, &Part1.exec/2) == 150
  end

  test "part2 example" do
    assert pilot(@example, &Part2.exec/2) == 900
  end
end
