defmodule Day05Test do
  use ExUnit.Case

  import Advent.Day05

  @example [
    "0,9 -> 5,9",
    "8,0 -> 0,8",
    "9,4 -> 3,4",
    "2,2 -> 2,1",
    "7,0 -> 7,4",
    "6,4 -> 2,0",
    "0,9 -> 2,9",
    "3,4 -> 1,4",
    "0,0 -> 8,8",
    "5,5 -> 8,2"
  ]

  test "part 1 example" do
    assert count_straight_overlap(@example) == 5
  end

  test "part 2 example" do
    assert count_overlap(@example) == 12
  end
end
