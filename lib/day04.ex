defmodule Advent.Day04 do
  alias Advent.Day04.Board

  def part1() do
    load_puzzle()
    |> play()
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

  def play(lines) do
    {nums, boards} = parse_puzzle(lines)

    Enum.reduce_while(nums, boards, fn num, boards ->
      {boards, winner} = mark(num, boards)

      if winner != nil do
        {:halt, Board.score(winner, num)}
      else
        {:cont, boards}
      end
    end)
  end

  def mark(num, boards) do
    updates = Enum.map(boards, &Board.mark(&1, num))
    winner = Enum.find(updates, &elem(&1, 1))
    boards = Enum.map(updates, &elem(&1, 0))

    if winner != nil do
      {boards, elem(winner, 0)}
    else
      {boards, nil}
    end
  end
end

defmodule Advent.Day04.Board do
  defstruct [:state, :coords]

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

    %Board{state: state, coords: coords}
  end

  def mark(%Board{state: state, coords: coords} = board, num) do
    coord = Map.get(coords, num)

    if coord == nil do
      {board, false}
    else
      state = %{state | coord => {num, true}}
      board = %Board{board | state: state}
      won = check(state, coord)
      {board, won}
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
