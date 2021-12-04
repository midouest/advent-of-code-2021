defmodule Advent.Day01 do
  def load_input() do
    "data/day01.txt"
    |> Advent.stream()
    |> Stream.map(&String.to_integer/1)
  end

  def part1() do
    load_input()
    |> count_increasing(1)
  end

  def part2() do
    load_input()
    |> count_increasing(3)
  end

  def count_increasing(depths, size) do
    depths
    |> Stream.chunk_every(size, 1, :discard)
    |> Stream.map(&Enum.sum/1)
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.count(fn [prev, next] -> next > prev end)
  end
end
