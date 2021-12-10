defmodule Advent.Day10 do
  def load_puzzle(), do: Advent.read("data/day10.txt")

  def part1() do
    load_puzzle()
    |> syntax_error_score()
  end

  def part2() do
    load_puzzle()
    |> autocomplete_score()
  end

  def syntax_error_score(lines) do
    lines
    |> filter_scores(:corrupted)
    |> Enum.sum()
  end

  def autocomplete_score(lines) do
    scores =
      lines
      |> filter_scores(:incomplete)
      |> Enum.sort()

    Enum.at(scores, div(length(scores), 2))
  end

  def filter_scores(lines, type) do
    lines
    |> Stream.map(&(String.graphemes(&1) |> close_braces([])))
    |> Stream.filter(&(elem(&1, 0) == type))
    |> Stream.map(&elem(&1, 1))
  end

  def close_braces([], incomplete), do: {:incomplete, total_incomplete_score(incomplete, 0)}

  def close_braces([char | line], []), do: close_braces(line, [close(char)])

  def close_braces([char | line], [close_char | rest] = expected) do
    cond do
      opens?(char) ->
        close_braces(line, [close(char) | expected])

      char == close_char ->
        close_braces(line, rest)

      true ->
        {:corrupted, corrupted_score(char)}
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

  def corrupted_score(")"), do: 3
  def corrupted_score("]"), do: 57
  def corrupted_score("}"), do: 1197
  def corrupted_score(">"), do: 25137

  def total_incomplete_score([], total), do: total

  def total_incomplete_score([char | rest], total) do
    total = total * 5 + incomplete_score(char)
    total_incomplete_score(rest, total)
  end

  def incomplete_score(")"), do: 1
  def incomplete_score("]"), do: 2
  def incomplete_score("}"), do: 3
  def incomplete_score(">"), do: 4
end
