defmodule Advent.Day21 do
  alias Advent.Day21.PracticeGame

  def load_puzzle(), do: Advent.read("data/day21.txt")

  def part1() do
    load_puzzle()
    |> play_practice_game()
  end

  def part2() do
    load_puzzle()
  end

  def play_practice_game(lines) do
    lines
    |> PracticeGame.parse()
    |> PracticeGame.play()
  end
end

defmodule Advent.Day21.PracticeGame do
  defstruct turn: 0,
            rolls: 0,
            spaces: nil,
            scores: [0, 0]

  alias __MODULE__, as: G

  def parse(lines) do
    [s1, s2] =
      lines
      |> Enum.map(fn line ->
        line
        |> String.slice(28..-1)
        |> String.to_integer()
      end)

    %G{spaces: [s1, s2]}
  end

  def play(%G{rolls: rolls} = g) do
    if over?(g) do
      losing_score(g) * rolls
    else
      g = take_turn(g)
      play(g)
    end
  end

  defp over?(%G{scores: [s1, s2]}), do: s1 >= 1000 or s2 >= 1000

  defp losing_score(%G{scores: [s1, s2]}) do
    cond do
      s1 >= 1000 ->
        s2

      s2 >= 1000 ->
        s1

      true ->
        nil
    end
  end

  defp take_turn(%G{turn: turn, rolls: rolls, spaces: spaces, scores: scores} = g) do
    if over?(g) do
      g
    else
      {total, rolls} = roll(rolls, 3)
      spaces = List.update_at(spaces, turn, &(Integer.mod(&1 + total - 1, 10) + 1))
      scores = List.update_at(scores, turn, &(&1 + Enum.at(spaces, turn)))
      turn = 1 - turn
      %G{turn: turn, rolls: rolls, spaces: spaces, scores: scores}
    end
  end

  defp roll(rolls, count), do: roll(rolls, count, 0)
  defp roll(rolls, 0, acc), do: {acc, rolls}

  defp roll(rolls, count, acc) do
    num = Integer.mod(rolls, 100) + 1
    roll(rolls + 1, count - 1, acc + num)
  end
end
