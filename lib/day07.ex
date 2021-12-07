defmodule Advent.Day07 do
  def load_puzzle(), do: Advent.read("data/day07.txt")

  def part1() do
    load_puzzle()
    |> solve_constant()
  end

  def part2() do
    load_puzzle()
    |> solve_increasing()
  end

  def solve_constant(input), do: solve(input, &Function.identity/1)
  def solve_increasing(input), do: solve(input, &sum_consecutive/1)

  def solve([line], fun) do
    crabs =
      line
      |> String.splitter(",")
      |> Enum.map(&String.to_integer/1)

    lower = Enum.min(crabs)
    upper = Enum.max(crabs)

    lower..upper
    |> Enum.reduce(nil, fn pos, min_cost ->
      pos
      |> cost(crabs, fun)
      |> min(min_cost)
    end)
  end

  def cost(pos, crabs, fun) do
    crabs
    |> Stream.map(&fun.(abs(&1 - pos)))
    |> Enum.sum()
  end

  def sum_consecutive(n), do: div(n * (n + 1), 2)
end
