defmodule Advent do
  @doc """
  Read and trim each line of the file at the given path
  """
  def read(path) do
    path
    |> stream()
    |> Enum.to_list()
  end

  @doc """
  Lazily read and trim each line of the file at the given path
  """
  def stream(path) do
    path
    |> File.open!([:read])
    |> IO.stream(:line)
    |> Stream.map(&String.trim/1)
  end

  @doc """
  Report the number of milliseconds it takes to execute the given function
  """
  def measure(fun) do
    start = Time.utc_now()
    result = fun.()
    dt = Time.diff(Time.utc_now(), start, :microsecond)
    ms = dt / 1000
    {result, ms}
  end

  @puzzles [
    Advent.Day01,
    Advent.Day02,
    Advent.Day03,
    Advent.Day04,
    Advent.Day05
  ]

  def main(args \\ []) do
    if check_help(args) == :cont do
      {day, part} = parse_args(args)

      @puzzles
      |> Stream.with_index()
      |> filter_day(day)
      |> Enum.each(&solve(&1, part))
    end
  end

  def check_help(["help"]) do
    IO.puts("./advent               # Solve all days")
    IO.puts("./advent <day>         # Solve only the given day")
    IO.puts("./advent <day> <part>  # Solve only the given day and part")
    IO.puts("")
    :halt
  end

  def check_help(_), do: :cont

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
    day =
      (index + 1)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    IO.puts(~s"Day #{day}")
    IO.puts("------")

    if part != 2 do
      {result, ms} = measure(&module.part1/0)
      IO.puts(~s"Part 1 = #{result} (#{ms} ms)")
    end

    if part != 1 do
      {result, ms} = measure(&module.part2/0)
      IO.puts(~s"Part 2 = #{result} (#{ms} ms)")
    end

    IO.puts("")
  end
end
