defmodule Advent.Day15 do
  alias Advent.Day15.Grid
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
      |> Grid.repeat(tiles)

    {width, height} = Grid.size(grid)

    nbs = fn coord -> Grid.neighbors(grid, coord) end
    dist = fn _, coord -> Grid.get(grid, coord) end
    h = dist

    astar({nbs, dist, h}, {0, 0}, {width - 1, height - 1})
    |> Enum.map(&Grid.get(grid, &1))
    |> Enum.sum()
  end
end

defmodule Advent.Day15.Grid do
  defstruct cells: Map.new(), width: 0, height: 0

  alias __MODULE__, as: Grid

  def parse(lines, fun \\ &Function.identity/1) do
    height = length(lines)
    width = String.length(List.first(lines))

    cells =
      lines
      |> Stream.map(fn line ->
        line
        |> String.graphemes()
        |> Stream.map(fun)
        |> Enum.with_index()
      end)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {cols, y}, cells ->
        Enum.reduce(cols, cells, fn {value, x}, cells ->
          Map.put(cells, {x, y}, value)
        end)
      end)

    %Grid{cells: cells, width: width, height: height}
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

  def size(%Grid{width: width, height: height}), do: {width, height}

  def get(%Grid{cells: cells}, coord), do: Map.fetch!(cells, coord)

  def neighbors(%Grid{width: width, height: height}, {x, y} = coord) do
    coords = if y > 0, do: [up(coord)], else: []
    coords = if y < height - 1, do: [down(coord) | coords], else: coords
    coords = if x > 0, do: [left(coord) | coords], else: coords
    if x < width - 1, do: [right(coord) | coords], else: coords
  end

  defp up({x, y}), do: {x, y - 1}
  defp down({x, y}), do: {x, y + 1}
  defp left({x, y}), do: {x - 1, y}
  defp right({x, y}), do: {x + 1, y}

  def print(
        %Grid{cells: cells, width: width, height: height},
        fun \\ &Function.identity/1,
        device \\ :stdio
      ) do
    IO.write(device, "\n")

    Enum.each(0..(height - 1), fn y ->
      Enum.each(0..(width - 1), fn x ->
        IO.write(device, fun.(Map.fetch!(cells, {x, y})))
      end)

      IO.write(device, "\n")
    end)

    IO.write(device, "\n")
  end
end
