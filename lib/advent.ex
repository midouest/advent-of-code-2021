defmodule Advent do
  def load(path) do
    path
    |> File.open!([:read])
    |> IO.stream(:line)
    |> Stream.map(&String.trim/1)
  end

  def to_integers(strings), do: Stream.map(strings, &to_integer/1)

  def to_integer(string), do: elem(Integer.parse(string), 0)
end
