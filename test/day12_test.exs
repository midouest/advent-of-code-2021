defmodule Day12Test do
  use ExUnit.Case

  import Advent.Day12

  @example1 [
    "start-A",
    "start-b",
    "A-c",
    "A-b",
    "b-d",
    "A-end",
    "b-end"
  ]

  @example2 [
    "dc-end",
    "HN-start",
    "start-kj",
    "dc-start",
    "dc-HN",
    "LN-dc",
    "HN-end",
    "kj-sa",
    "kj-HN",
    "kj-dc"
  ]

  @example3 [
    "fs-end",
    "he-DX",
    "fs-he",
    "start-DX",
    "pj-DX",
    "end-zg",
    "zg-sl",
    "zg-pj",
    "pj-he",
    "RW-he",
    "fs-DX",
    "pj-RW",
    "zg-RW",
    "start-pj",
    "he-WI",
    "zg-he",
    "pj-fs",
    "start-RW"
  ]

  test "part 1 example 1" do
    assert count_paths(@example1) == 10
  end

  test "part 1 example 2" do
    assert count_paths(@example2) == 19
  end

  test "part 1 example 3" do
    assert count_paths(@example3) == 226
  end

  test "part 2 example 1" do
    assert count_paths(@example1, 2) == 36
  end

  test "part 2 example 2" do
    assert count_paths(@example2, 2) == 103
  end

  test "part 2 example 3" do
    assert count_paths(@example3, 2) == 3509
  end
end
