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
    |> lowest_risk_path(5)
  end

  def lowest_risk_path(lines, tiles \\ 1) do
    grid =
      lines
      |> Grid.parse(&String.to_integer/1)
      |> repeat(tiles)

    {width, height} = Grid.size(grid)

    nbs = fn coord -> Grid.neighbors(grid, coord) end
    dist = fn _, coord -> Grid.get(grid, coord) end
    h = dist

    astar({nbs, dist, h}, {0, 0}, {width - 1, height - 1})
    |> Enum.map(&Grid.get(grid, &1))
    |> Enum.sum()
  end

  def repeat(%Grid{cells: cells, width: width, height: height}, tiles) do
    cells =
      for tile_y <- 0..(tiles - 1),
          tile_x <- 0..(tiles - 1),
          {tile_x, tile_y} != {0, 0},
          reduce: cells do
        cells ->
          for {{x, y}, risk} <- cells, reduce: cells do
            cells ->
              risk = Integer.mod(risk - 1 + tile_x + tile_y, 9) + 1
              coord = {width * tile_x + x, height * tile_y + y}
              Map.put(cells, coord, risk)
          end
      end

    %Grid{cells: cells, width: width * tiles, height: height * tiles}
  end
end
