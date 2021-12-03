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
    assert decode(@example) == 198
  end
end
