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
      nums
      |> String.splitter(",")
      |> Enum.map(&String.to_integer/1)

    boards =
      lines
      |> Stream.chunk_every(5, 6, :discard)
      |> Enum.map(&Board.parse/1)

    {nums, boards}
  end

  def first_winner_score(lines) do
    lines
    |> play_until(fn _, scores -> length(scores) == 1 end)
    |> List.first()
  end

  def last_winner_score(lines) do
    lines
    |> play_until(&(length(&1) == length(&2)))
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
      updates
      |> Stream.filter(&elem(&1, 1))
      |> Stream.map(&elem(&1, 0))
      |> Enum.map(&Board.score(&1, num))

    boards = Enum.map(updates, &elem(&1, 0))

    {boards, scores}
  end
end

defmodule Advent.Day04.Board do
  defstruct [:state, :coords, :won]

  alias __MODULE__, as: Board

  def parse(lines) do
    {state, coords} =
      lines
      |> Stream.with_index()
      |> Enum.reduce({%{}, %{}}, &parse_line/2)

    %Board{state: state, coords: coords, won: false}
  end

  defp parse_line({line, row}, acc) do
    line
    |> String.splitter(" ")
    |> Stream.filter(&(&1 != ""))
    |> Stream.with_index()
    |> Stream.map(fn {data, col} -> {data, {row, col}} end)
    |> Enum.reduce(acc, &put_cell/2)
  end

  defp put_cell({data, coord}, {state, coords}) do
    num = String.to_integer(data)
    state = Map.put(state, coord, {num, false})
    coords = Map.put(coords, num, coord)
    {state, coords}
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
        won = won?(state, coord)
        board = %Board{board | state: state, won: won}
        {board, won}
      end
    end
  end

  def score(%Board{state: state}, num) do
    sum =
      state
      |> Map.values()
      |> Stream.filter(&(not elem(&1, 1)))
      |> Stream.map(&elem(&1, 0))
      |> Enum.sum()

    sum * num
  end

  defp won?(state, {row, col}) do
    row_coords(row) |> all_marked?(state) or col_coords(col) |> all_marked?(state)
  end

  defp row_coords(row), do: Stream.map(0..4, &{row, &1})
  defp col_coords(col), do: Stream.map(0..4, &{&1, col})
  defp all_marked?(coords, state), do: Enum.all?(coords, &elem(state[&1], 1))
end
