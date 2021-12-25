defmodule Day25Test do
  use ExUnit.Case

  import Advent.Day25

  @example [
    "v...>>.vv>",
    ".vv>>.vv..",
    ">>.>v>...v",
    ">>v>>.>.v.",
    "v>v.vv.v..",
    ">.>>..v...",
    ".vv..>.>v.",
    "v.v..>>v.v",
    "....v..v.>"
  ]

  test "part 1 example" do
    assert settle(@example) == 58
  end
end
