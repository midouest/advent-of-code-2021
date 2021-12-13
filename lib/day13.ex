defmodule Advent.Day13 do
  alias Advent.Day13.Paper

  def load_puzzle(), do: Advent.read("data/day13.txt")

  def part1() do
    load_puzzle()
    |> count_visible()
  end

  def part2() do
    {paper, folds} =
      load_puzzle()
      |> Paper.parse()

    Enum.reduce(folds, paper, &Paper.fold(&2, &1))
    |> Paper.print()
  end

  def count_visible(lines) do
    {paper, [fold | _]} = Paper.parse(lines)

    Paper.fold(paper, fold)
    |> Paper.count_dots()
  end
end

defmodule Advent.Day13.Paper do
  defstruct [:coords, :width, :height]

  alias __MODULE__, as: Paper

  def parse(lines) do
    {coords, ["" | folds]} = Enum.split_while(lines, &(&1 != ""))

    {coords, max_x, max_y} =
      Enum.map(coords, fn line ->
        String.split(line, ",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> Enum.reduce({MapSet.new(), 0, 0}, fn {x, y} = coord, {coords, max_x, max_y} ->
        {MapSet.put(coords, coord), max(max_x, x), max(max_y, y)}
      end)

    folds =
      Enum.map(folds, fn line ->
        [axis | [value]] =
          String.slice(line, 11..String.length(line))
          |> String.split("=")

        {axis, String.to_integer(value)}
      end)

    {%Paper{coords: coords, width: max_x + 1, height: max_y + 1}, folds}
  end

  def fold(%Paper{coords: coords} = paper, {"x", column}) do
    coords =
      MapSet.to_list(coords)
      |> Enum.reduce(MapSet.new(), fn {x, y}, coords ->
        x = if x < column, do: x, else: 2 * column - x
        MapSet.put(coords, {x, y})
      end)

    %Paper{paper | coords: coords, width: column}
  end

  def fold(%Paper{coords: coords} = paper, {"y", row}) do
    coords =
      MapSet.to_list(coords)
      |> Enum.reduce(MapSet.new(), fn {x, y}, coords ->
        y = if y < row, do: y, else: 2 * row - y
        MapSet.put(coords, {x, y})
      end)

    %Paper{paper | coords: coords, height: row}
  end

  def count_dots(%Paper{coords: coords}), do: MapSet.to_list(coords) |> length()

  def print(%Paper{coords: coords, width: width, height: height}) do
    IO.write("\n")

    Enum.each(0..(height - 1), fn y ->
      Enum.each(0..(width - 1), fn x ->
        IO.write(if MapSet.member?(coords, {x, y}), do: "#", else: " ")
      end)

      IO.write("\n")
    end)

    IO.write("\n")
  end
end
