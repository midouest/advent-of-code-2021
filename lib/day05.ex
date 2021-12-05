defmodule Advent.Day05 do
  def load_puzzle(), do: Advent.stream("data/day05.txt")

  def part1() do
    load_puzzle()
    |> count_straight_overlap()
  end

  def part2() do
    load_puzzle()
    |> count_all_overlap()
  end

  def count_straight_overlap(lines), do: count_overlap(lines, &straight?/1)
  def count_all_overlap(lines), do: count_overlap(lines, &Function.identity/1)

  def count_overlap(lines, fun) do
    lines
    |> Stream.map(&parse/1)
    |> Stream.filter(fun)
    |> Enum.reduce(%{}, &mark_line/2)
    |> Map.values()
    |> Enum.count(&(&1 > 1))
  end

  def parse(line) do
    line
    |> String.splitter(" -> ")
    |> Enum.map(&parse_coord/1)
    |> List.to_tuple()
  end

  def parse_coord(coord) do
    coord
    |> String.splitter(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def straight?(line), do: horizontal?(line) or vertical?(line)
  def horizontal?({{_, y1}, {_, y2}}), do: y1 == y2
  def vertical?({{x1, _}, {x2, _}}), do: x1 == x2

  def coords({{x1, y1}, {x2, y2}} = line) do
    cond do
      horizontal?(line) ->
        Enum.map(x1..x2, &{&1, y1})

      vertical?(line) ->
        Enum.map(y1..y2, &{x1, &1})

      true ->
        Enum.zip_with(x1..x2, y1..y2, &{&1, &2})
    end
  end

  def mark_line(line, map) do
    line
    |> coords()
    |> Enum.reduce(map, &mark_coord/2)
  end

  def mark_coord(coord, map) do
    map
    |> Map.get_and_update(coord, &increment/1)
    |> elem(1)
  end

  def increment(count) do
    if count == nil do
      {count, 1}
    else
      {count, count + 1}
    end
  end
end
