defmodule Day01Test do
  use ExUnit.Case

  @example [
    199,
    200,
    208,
    210,
    200,
    207,
    240,
    269,
    260,
    263
  ]

  test "part1 example" do
    count = Advent.Day01.count_increasing(@example, 1)
    assert count == 7
  end

  test "part2 example" do
    count = Advent.Day01.count_increasing(@example, 3)
    assert count == 5
  end
end
