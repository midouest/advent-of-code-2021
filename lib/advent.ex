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

  def measure(fun) do
    start = Time.utc_now()
    result = fun.()
    dt = Time.diff(Time.utc_now(), start, :microsecond)
    ms = dt / 1000
    IO.puts(~s"#{ms} ms")
    result
  end
end
