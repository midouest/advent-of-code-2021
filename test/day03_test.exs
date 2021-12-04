defmodule Day03Test do
  use ExUnit.Case

  import Advent.Day03

  @example [
    "00100",
    "11110",
    "10110",
    "10111",
    "10101",
    "01111",
    "00111",
    "11100",
    "10000",
    "11001",
    "00010",
    "01010"
  ]

  test "part1 example" do
    assert decode_power(@example) == 198
  end

  test "part2 example" do
    assert decode_life_support(@example) == 230
  end
end
