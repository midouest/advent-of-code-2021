defmodule Advent.Day10 do
  def load_puzzle(), do: Advent.read("data/day10.txt")

  def part1() do
    load_puzzle()
    |> syntax_error_score()
  end

  def part2() do
    load_puzzle()
  end

  def syntax_error_score(lines) do
    lines
    |> Stream.map(&(String.graphemes(&1) |> close_braces([])))
    |> Stream.filter(&(elem(&1, 0) == :corrupted))
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def close_braces([], _), do: {:incomplete, 0}
  def close_braces([char | line], []), do: close_braces(line, [close(char)])

  def close_braces([char | line], [close_char | rest] = expected) do
    cond do
      opens?(char) ->
        close_braces(line, [close(char) | expected])

      char == close_char ->
        close_braces(line, rest)

      true ->
        {:corrupted, score(char)}
    end
  end

  def opens?("("), do: true
  def opens?("["), do: true
  def opens?("{"), do: true
  def opens?("<"), do: true
  def opens?(_), do: false

  def close("("), do: ")"
  def close("["), do: "]"
  def close("{"), do: "}"
  def close("<"), do: ">"

  def score(")"), do: 3
  def score("]"), do: 57
  def score("}"), do: 1197
  def score(">"), do: 25137
end
