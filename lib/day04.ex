defmodule Advent.Day04 do
  alias Advent.Day04.Board

  def part1() do
    load_puzzle()
    |> first_winner_score()
  end

  def part2() do
    load_puzzle()
    |> last_winner_score()
  end

  def load_puzzle(), do: Advent.read("data/day04.txt")

  def parse_puzzle(lines) do
    [nums | [_ | lines]] = lines

    nums =
      String.splitter(nums, ",")
      |> Enum.map(&String.to_integer/1)

    boards =
      Stream.chunk_every(lines, 5, 6, :discard)
      |> Enum.map(&Board.parse/1)

    {nums, boards}
  end

  def first_winner_score(lines) do
    play_until(lines, fn _, scores -> length(scores) == 1 end)
    |> List.first()
  end

  def last_winner_score(lines) do
    play_until(lines, &(length(&1) == length(&2)))
    |> List.last()
  end

  def play_until(lines, fun) do
    {nums, boards} = parse_puzzle(lines)

    Enum.reduce_while(nums, {boards, []}, fn num, {boards, prev_scores} ->
      {boards, scores} = mark(num, boards)

      next_scores = prev_scores ++ scores

      if fun.(boards, next_scores) do
        {:halt, next_scores}
      else
        {:cont, {boards, next_scores}}
      end
    end)
  end

  def mark(num, boards) do
    updates = Enum.map(boards, &Board.mark(&1, num))

    scores =
      Stream.filter(updates, &elem(&1, 1))
      |> Stream.map(&elem(&1, 0))
      |> Enum.map(&Board.score(&1, num))

    boards = Enum.map(updates, &elem(&1, 0))

    {boards, scores}
  end
end

defmodule Advent.Day04.Board do
  defstruct [:state, :coords, :won]

  alias __MODULE__, as: Board

  def parse(rows) do
    {state, coords} =
      Stream.with_index(rows)
      |> Enum.reduce({%{}, %{}}, fn {line, row}, acc ->
        String.splitter(line, " ")
        |> Stream.filter(&(&1 != ""))
        |> Stream.with_index()
        |> Enum.reduce(acc, fn {data, col}, {state, coords} ->
          coord = {row, col}
          num = String.to_integer(data)
          state = Map.put(state, coord, {num, false})
          coords = Map.put(coords, num, coord)
          {state, coords}
        end)
      end)

    %Board{state: state, coords: coords, won: false}
  end

  def mark(%Board{state: state, coords: coords, won: won} = board, num) do
    if won do
      {board, false}
    else
      coord = Map.get(coords, num)

      if coord == nil do
        {board, false}
      else
        state = %{state | coord => {num, true}}
        won = check(state, coord)
        board = %Board{board | state: state, won: won}
        {board, won}
      end
    end
  end

  def score(%Board{state: state}, num) do
    sum =
      Map.values(state)
      |> Stream.filter(&(not elem(&1, 1)))
      |> Stream.map(&elem(&1, 0))
      |> Enum.sum()

    sum * num
  end

  defp check(state, {row, col}) do
    row_stream(row)
    |> check_coords(state) or
      col_stream(col)
      |> check_coords(state)
  end

  defp row_stream(row), do: Stream.map(0..4, &{row, &1})
  defp col_stream(col), do: Stream.map(0..4, &{&1, col})
  defp check_coords(coords, state), do: Enum.all?(coords, &elem(state[&1], 1))
end
