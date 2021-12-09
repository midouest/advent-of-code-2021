defmodule Advent.Day09 do
  def load_puzzle(), do: Advent.stream("data/day09.txt")

  def part1() do
    load_puzzle()
    |> risk_level()
  end

  def part2() do
    load_puzzle()
  end

  def parse(lines) do
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
  end

  def risk_level(lines) do
    map = parse(lines)

    local_min(map)
    |> Stream.map(&(&1 + 1))
    |> Enum.sum()
  end

  defp local_min(map) do
    Enum.reduce(map, [], fn {coord, height}, minima ->
      min = min_neighbors(coord, map)

      if height < min do
        [height | minima]
      else
        minima
      end
    end)
  end

  defp min_neighbors(coord, map) do
    neighbors(coord, map)
    |> Enum.reduce(nil, &min(&1, &2))
  end

  defp neighbors(coord, map) do
    [up(coord, map), down(coord, map), left(coord, map), right(coord, map)]
    |> Enum.filter(&(&1 != nil))
  end

  defp up({row, col}, map), do: Map.get(map, {row - 1, col})
  defp down({row, col}, map), do: Map.get(map, {row + 1, col})
  defp left({row, col}, map), do: Map.get(map, {row, col - 1})
  defp right({row, col}, map), do: Map.get(map, {row, col + 1})
end
