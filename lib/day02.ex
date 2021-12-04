defmodule Advent.Day02 do
  def load_input(), do: Advent.stream("data/day02.txt")

  def part1() do
    load_input()
    |> pilot(&part1_exec/2)
  end

  def part2() do
    load_input()
    |> pilot(&part2_exec/2)
  end

  def parse(line) do
    [direction, delta_str] = String.split(line, " ")
    delta = String.to_integer(delta_str)
    {direction, delta}
  end

  def pilot(commands, exec) do
    {x, y, _} =
      commands
      |> Stream.map(&parse/1)
      |> Enum.reduce({0, 0, 0}, exec)

    x * y
  end

  def part1_exec({"forward", d}, {x, y, a}), do: {x + d, y, a}
  def part1_exec({"up", d}, {x, y, a}), do: {x, y - d, a}
  def part1_exec({"down", d}, {x, y, a}), do: {x, y + d, a}

  def part2_exec({"forward", d}, {x, y, a}), do: {x + d, y + a * d, a}
  def part2_exec({"up", d}, {x, y, a}), do: {x, y, a - d}
  def part2_exec({"down", d}, {x, y, a}), do: {x, y, a + d}
end
