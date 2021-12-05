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

  def main(_args \\ []) do
    @puzzles
    |> Stream.with_index()
    |> Enum.each(&exec/1)
  end

  def exec({module, index}) do
    day =
      (index + 1)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    IO.puts(~s"Day #{day}")
    IO.puts("------")
    {result, ms} = measure(&module.part1/0)
    IO.puts(~s"Part 1 = #{result} (#{ms} ms)")
    {result, ms} = measure(&module.part2/0)
    IO.puts(~s"Part 2 = #{result} (#{ms} ms)\n")
  end
end
