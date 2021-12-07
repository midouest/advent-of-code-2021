defmodule Advent.Day06 do
  def load_puzzle(), do: Advent.read("data/day06.txt")

  def part1() do
    load_puzzle()
    |> simulate(80)
  end

  def part2() do
    load_puzzle()
    |> simulate(256)
  end

  def simulate([line], days) do
    counts =
      line
      |> String.splitter(",")
      |> Stream.map(&String.to_integer/1)
      |> Enum.frequencies()

    initial = Enum.map(0..8, &Map.get(counts, &1, 0))

    1..days
    |> Enum.reduce(initial, &tick/2)
    |> Enum.sum()
  end

  def tick(_, [zeroes | rest]) do
    rest
    |> Kernel.++([zeroes])
    |> List.update_at(6, &(&1 + zeroes))
  end
end
