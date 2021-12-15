defmodule Advent.Grid do
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
