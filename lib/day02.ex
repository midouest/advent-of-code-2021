defmodule Advent.Day02 do
  alias Advent.Day02.{Part1, Part2}

  def load_input(), do: Advent.load("data/day02.txt")

  def part1() do
    load_input()
    |> pilot(&Part1.exec/2)
  end

  def part2() do
    load_input()
    |> pilot(&Part2.exec/2)
  end

  def parse(line) do
    [direction, string] = String.split(line, " ")
    {amount, _} = Integer.parse(string)
    {direction, amount}
  end

  def pilot(commands, exec) do
    {x, y, _} =
      commands
      |> Stream.map(&parse/1)
      |> Enum.reduce({0, 0, 0}, exec)

    x * y
  end

  defmodule Part1 do
    def exec({"forward", d}, {x, y, a}), do: {x + d, y, a}
    def exec({"up", d}, {x, y, a}), do: {x, y - d, a}
    def exec({"down", d}, {x, y, a}), do: {x, y + d, a}
  end

  defmodule Part2 do
    def exec({"forward", d}, {x, y, a}), do: {x + d, y + a * d, a}
    def exec({"up", d}, {x, y, a}), do: {x, y, a - d}
    def exec({"down", d}, {x, y, a}), do: {x, y, a + d}
  end
end
