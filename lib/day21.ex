defmodule Advent.Day21 do
  alias Advent.Day21.Game
  alias Advent.Day21.DeterministicDie

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
    |> Game.parse(DeterministicDie.new())
    |> Game.play()
  end
end

defmodule Advent.Day21.Game do
  defstruct turn: 0,
            die: nil,
            rolls: 0,
            spaces: nil,
            scores: [0, 0]

  alias __MODULE__, as: G
  alias Advent.Day21.Rollable
  alias Advent.Day21.Roller

  @spec parse(list(binary()), Rollable.t()) :: %G{}
  def parse(lines, die) do
    [s1, s2] =
      lines
      |> Enum.map(fn line ->
        line
        |> String.slice(28..-1)
        |> String.to_integer()
      end)

    new(die, s1, s2)
  end

  @spec new(Rollable.t(), non_neg_integer(), non_neg_integer()) :: %G{}
  def new(die, s1, s2), do: %G{die: die, spaces: [s1, s2]}

  def play(%G{rolls: rolls} = g) do
    if over?(g) do
      losing_score(g) * rolls
    else
      g = take_turn(g)
      play(g)
    end
  end

  def over?(%G{scores: [s1, s2]}), do: s1 >= 1000 or s2 >= 1000

  def losing_score(%G{scores: [s1, s2]}) do
    cond do
      s1 >= 1000 ->
        s2

      s2 >= 1000 ->
        s1

      true ->
        nil
    end
  end

  def take_turn(%G{turn: turn, die: die, rolls: rolls, spaces: spaces, scores: scores} = g) do
    if over?(g) do
      g
    else
      {total, die} = Roller.roll(die, 3)
      rolls = rolls + 3
      spaces = List.update_at(spaces, turn, &(Integer.mod(&1 + total - 1, 10) + 1))
      scores = List.update_at(scores, turn, &(&1 + Enum.at(spaces, turn)))
      turn = 1 - turn
      %G{turn: turn, die: die, rolls: rolls, spaces: spaces, scores: scores}
    end
  end
end

defprotocol Advent.Day21.Rollable do
  @spec roll(t()) :: {integer(), t()}
  def roll(_)
end

defmodule Advent.Day21.Roller do
  alias Advent.Day21.Rollable

  @spec roll(Rollable.t(), non_neg_integer()) :: {integer(), Rollable.t()}
  def roll(die, count), do: reducer(die, count, 0)

  defp reducer(die, 0, acc), do: {acc, die}

  defp reducer(die, count, acc) do
    {num, die} = Rollable.roll(die)
    reducer(die, count - 1, acc + num)
  end
end

defmodule Advent.Day21.DeterministicDie do
  defstruct num: 1

  alias __MODULE__, as: D
  alias Advent.Day21.Rollable

  def new(), do: %D{}

  defimpl Rollable, for: D do
    def roll(%D{num: num}) do
      next_num = Integer.mod(num, 100) + 1
      {num, %D{num: next_num}}
    end
  end
end
