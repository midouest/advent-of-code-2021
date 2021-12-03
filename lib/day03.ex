defmodule Advent.Day03 do
  def load_puzzle(), do: Advent.read("data/day03.txt")

  def part1() do
    load_puzzle()
    |> decode()
  end

  def decode(lines) do
    num_lines = length(lines)
    num_digits = String.length(List.first(lines))
    min_count = num_lines / 2

    counts =
      lines
      |> Stream.map(fn line ->
        String.graphemes(line)
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.reduce(fn bits, counts -> Enum.zip_with(bits, counts, &+/2) end)

    gamma =
      counts
      |> Enum.map(&if &1 > min_count, do: 1, else: 0)
      |> Integer.undigits(2)

    epsilon = Bitwise.bxor(gamma, Integer.pow(2, num_digits) - 1)

    gamma * epsilon
  end
end
