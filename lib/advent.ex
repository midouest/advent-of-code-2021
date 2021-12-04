defmodule Advent do
  def read(path) do
    path
    |> stream()
    |> Enum.to_list()
  end

  def stream(path) do
    path
    |> File.open!([:read])
    |> IO.stream(:line)
    |> Stream.map(&String.trim/1)
  end

  def to_integers(strings), do: Stream.map(strings, &String.to_integer/1)
end
