defmodule Day23Test do
  use ExUnit.Case

  import Advent.Day23

  @example [
    "#############",
    "#...........#",
    "###B#C#B#D###",
    "  #A#D#C#A#  ",
    "  #########  "
  ]

  test "part 1 example" do
    assert organize(@example) == 12521
  end

  # @tag timeout: :infinity
  # test "part 2 example" do
  #   assert organize(@example, true) == 44169
  # end
end
