defmodule Advent.Day02 do
  defmodule Instruction do
    def parse(line) do
      [direction, s] = String.split(line, " ")
      {amount, _} = Integer.parse(s)
      {direction, amount}
    end

    def eval({"forward", d}, {x, y}), do: {x + d, y}
    def eval({"up", d}, {x, y}), do: {x, y - d}
    def eval({"down", d}, {x, y}), do: {x, y + d}
  end

  def load_input(), do: Advent.load("data/day02.txt")

  def part1() do
    load_input()
    |> pilot()
  end

  def pilot(instructions) do
    {x, y} =
      instructions
      |> Stream.map(&Instruction.parse/1)
      |> Enum.reduce({0, 0}, &Instruction.eval/2)

    x * y
  end
end
