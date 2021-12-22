defmodule Advent.Day21 do
  alias Advent.Day21.PracticeGame
  alias Advent.Day21.DiracGame

  def load_puzzle(), do: Advent.read("data/day21.txt")

  def part1() do
    load_puzzle()
    |> play_practice_game()
  end

  def part2() do
    load_puzzle()
    |> play_dirac_game()
  end

  def play_practice_game(lines) do
    lines
    |> parse()
    |> PracticeGame.new()
    |> PracticeGame.play()
  end

  def play_dirac_game(lines) do
    lines
    |> parse()
    |> DiracGame.new()
    |> DiracGame.play()
    |> DiracGame.most_wins()
  end

  def parse(lines) do
    lines
    |> Enum.map(fn line ->
      line
      |> String.slice(28..-1)
      |> String.to_integer()
    end)
  end
end

defmodule Advent.Day21.PracticeGame do
  defstruct turn: 0,
            rolls: 0,
            spaces: nil,
            scores: [0, 0]

  alias __MODULE__, as: G

  def new([_, _] = spaces), do: %G{spaces: spaces}

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

defmodule Advent.Day21.DiracGame do
  defstruct counts: nil, turn: 0, wins: [0, 0]

  alias __MODULE__, as: G
  alias Advent.Day21.DiracState

  def new([_, _] = spaces) do
    %G{counts: %{DiracState.new(spaces) => 1}}
  end

  def most_wins(%G{wins: wins}), do: Enum.max(wins)

  def play(%G{counts: counts} = g) when map_size(counts) == 0, do: g

  def play(%G{} = g) do
    step(g)
    |> play()
  end

  def step(%G{counts: counts} = g) when map_size(counts) == 0, do: g

  def step(%G{counts: counts, turn: turn} = g) do
    acc = %G{g | counts: %{}}
    g = Enum.reduce(counts, acc, &step_state/2)
    %G{g | turn: 1 - turn}
  end

  defp step_state({state, prev_count}, %G{turn: turn} = g) do
    states = DiracState.next(state, turn)

    Enum.reduce(states, g, fn {state, next_count}, %G{counts: counts, wins: wins} = g ->
      count = prev_count * next_count

      case DiracState.winner?(state) do
        nil ->
          counts = Map.update(counts, state, count, &(&1 + count))
          %G{g | counts: counts}

        n ->
          wins = List.update_at(wins, n, &(&1 + count))
          %G{g | wins: wins}
      end
    end)
  end
end

defmodule Advent.Day21.DiracState do
  defstruct spaces: nil, scores: [0, 0]

  alias __MODULE__, as: S

  def new([_, _] = spaces), do: %S{spaces: spaces}

  @rolls %{3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}

  def next(%S{} = s, turn) do
    Enum.map(@rolls, fn {n, count} -> {roll(s, turn, n), count} end)
  end

  def winner?(%S{scores: [s1, _]}) when s1 >= 21, do: 0
  def winner?(%S{scores: [_, s2]}) when s2 >= 21, do: 1
  def winner?(_), do: nil

  def roll(%S{spaces: spaces, scores: scores}, turn, n) do
    spaces = List.update_at(spaces, turn, &(Integer.mod(&1 + n - 1, 10) + 1))
    scores = List.update_at(scores, turn, &(&1 + Enum.at(spaces, turn)))
    %S{spaces: spaces, scores: scores}
  end
end
