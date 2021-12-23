defmodule Advent do
  @doc """
  Read and trim each line of the file at the given path
  """
  def read(path, fun \\ &String.trim/1) do
    path
    |> stream(fun)
    |> Enum.to_list()
  end

  @doc """
  Lazily read and trim each line of the file at the given path
  """
  def stream(path, fun \\ &String.trim/1) do
    path
    |> File.open!([:read])
    |> IO.stream(:line)
    |> Stream.map(fun)
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

  def pad_day(day) do
    day
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
