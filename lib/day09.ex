defmodule Advent.Day09 do
  alias Advent.Day09.Grid

  def load_puzzle(), do: Advent.read("data/day09.txt")

  def part1() do
    load_puzzle()
    |> risk_level()
  end

  def part2() do
    load_puzzle()
    |> basin_product()
  end

  def risk_level(lines) do
    lines
    |> Grid.parse()
    |> local_min()
    |> Stream.map(fn {_, height} -> height + 1 end)
    |> Enum.sum()
  end

  def basin_product(lines) do
    grid = Grid.parse(lines)

    grid
    |> local_min()
    |> Stream.map(fn {coord, _} ->
      coord
      |> find_basin(grid)
      |> MapSet.size()
    end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(3)
    |> Enum.product()
  end

  defp find_basin(coord, grid) do
    frontier = [coord]
    basin = MapSet.new(frontier)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({frontier, basin}, fn _, {frontier, basin} ->
      expand_basin(frontier, basin, grid)
    end)
  end

  defp expand_basin([], basin, _), do: {:halt, basin}

  defp expand_basin([coord | frontier], basin, grid) do
    neighbors =
      Grid.neighbors(grid, coord)
      |> Enum.filter(fn coord ->
        not MapSet.member?(basin, coord) and Grid.fetch!(grid, coord) != 9
      end)

    frontier = frontier ++ neighbors
    basin = MapSet.union(basin, MapSet.new(neighbors))

    {:cont, {frontier, basin}}
  end

  defp local_min(grid) do
    grid
    |> Grid.coords()
    |> Enum.reduce([], fn {coord, height}, minima ->
      min = min_neighbors(coord, grid)

      if height < min do
        [{coord, height} | minima]
      else
        minima
      end
    end)
  end

  defp min_neighbors(coord, grid) do
    neighbor_heights(coord, grid)
    |> Enum.reduce(nil, &min(&1, &2))
  end

  defp neighbor_heights(coord, grid) do
    Grid.neighbors(grid, coord)
    |> Enum.map(&Grid.fetch!(grid, &1))
  end
end

defmodule Advent.Day09.Grid do
  defstruct [:map, :size]

  alias __MODULE__, as: Grid

  def parse(lines) do
    height = length(lines)
    width = String.length(List.first(lines))

    map =
      lines
      |> Stream.map(fn line ->
        line
        |> String.graphemes()
        |> Stream.map(&String.to_integer/1)
        |> Enum.with_index()
      end)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {cols, row}, map ->
        Enum.reduce(cols, map, fn {height, col}, map ->
          Map.put(map, {row, col}, height)
        end)
      end)

    %Grid{map: map, size: {width, height}}
  end

  def coords(%Grid{map: map}), do: map

  def fetch!(%Grid{map: map}, coord), do: Map.fetch!(map, coord)

  def neighbors(%Grid{size: {width, height}}, {row, col} = coord) do
    coords = if row > 0, do: [up(coord)], else: []
    coords = if row < height - 1, do: [down(coord) | coords], else: coords
    coords = if col > 0, do: [left(coord) | coords], else: coords
    if col < width - 1, do: [right(coord) | coords], else: coords
  end

  defp up({row, col}), do: {row - 1, col}
  defp down({row, col}), do: {row + 1, col}
  defp left({row, col}), do: {row, col - 1}
  defp right({row, col}), do: {row, col + 1}
end
