defmodule Day14Test do
  use ExUnit.Case

  import Advent.Day14

  @example [
    "NNCB",
    "",
    "CH -> B",
    "HH -> N",
    "CB -> H",
    "NH -> C",
    "HB -> C",
    "HC -> B",
    "HN -> C",
    "NN -> C",
    "BH -> H",
    "NC -> B",
    "NB -> B",
    "BN -> B",
    "BB -> N",
    "BC -> B",
    "CC -> N",
    "CN -> C"
  ]

  test "part 1 example" do
    assert most_least_difference(@example, 10) == 1588
  end

  test "part 2 example" do
    assert most_least_difference(@example, 40) == 2_188_189_693_529
  end
end
