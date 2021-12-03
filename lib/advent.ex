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

  def to_integers(strings), do: Stream.map(strings, &to_integer/1)

  def to_integer(string), do: elem(Integer.parse(string), 0)

  def bool_to_integer(bool) do
    if bool, do: 1, else: 0
  end
end
