defmodule Advent.Day15 do
  alias Advent.Grid
  import Astar

  def load_puzzle(), do: Advent.read("data/day15.txt")

  def part1() do
    load_puzzle()
    |> lowest_risk_path()
  end

  def part2() do
    load_puzzle()
  end

  def lowest_risk_path(lines) do
    grid = Grid.parse(lines, &String.to_integer/1)
    {width, height} = Grid.size(grid)

    nbs = fn coord -> Grid.neighbors(grid, coord) end
    dist = fn _, coord -> Grid.fetch!(grid, coord) end
    h = dist

    astar({nbs, dist, h}, {0, 0}, {width - 1, height - 1})
    |> Enum.map(&Grid.fetch!(grid, &1))
    |> Enum.sum()
  end
end
