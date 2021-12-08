defmodule Advent.Day08 do
  def load_puzzle(), do: Advent.read("data/day08.txt")

  def part1() do
    load_puzzle()
    |> count_all_1478()
  end

  def part2() do
    load_puzzle()
  end

  def parse(lines) do
    lines
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.splitter(" | ")
    |> Enum.map(&String.split(&1, " "))
    |> List.to_tuple()
  end

  def count_all_1478(lines) do
    lines
    |> parse()
    |> Stream.map(&count_1478/1)
    |> Enum.sum()
  end

  def count_1478({_, output}) do
    output
    |> Enum.reduce(0, fn signal, count ->
      len = String.length(signal)

      cond do
        len == 2 or len == 3 or len == 4 or len == 7 ->
          count + 1

        true ->
          count
      end
    end)
  end
end
