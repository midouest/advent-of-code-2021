defmodule Advent.CLI do
  def main(args \\ []) do
    {day, part} =
      args
      |> print_help()
      |> parse_args()

    Advent.Puzzles.all()
    |> Stream.with_index()
    |> filter_day(day)
    |> Enum.each(&solve(&1, part))
  end

  def print_help(["help"]) do
    IO.puts("./advent               # Solve all days")
    IO.puts("./advent <day>         # Solve only the given day (1-25)")
    IO.puts("./advent <day> <part>  # Solve only the given day and part (1-2)")
    IO.puts("")
    System.halt()
  end

  def print_help(args), do: args

  def parse_args(args) do
    args
    |> Stream.map(&String.to_integer/1)
    |> Enum.take(2)
    |> to_arg_tuple()
  end

  def to_arg_tuple([]), do: {nil, nil}
  def to_arg_tuple([day]), do: {day, nil}
  def to_arg_tuple([day | [part]]), do: {day, part}

  def filter_day(stream, day) do
    if day != nil do
      Stream.filter(stream, &(elem(&1, 1) == day - 1))
    else
      stream
    end
  end

  def solve({module, index}, part) do
    day = Advent.pad_day(index + 1)

    IO.puts(~s"Day #{day}")
    IO.puts("------")

    if part != 2 do
      {result, ms} = Advent.measure(&module.part1/0)
      IO.puts(~s"Part 1 = #{result} (#{ms} ms)")
    end

    if part != 1 do
      {result, ms} = Advent.measure(&module.part2/0)
      IO.puts(~s"Part 2 = #{result} (#{ms} ms)")
    end

    IO.puts("")
  end
end
