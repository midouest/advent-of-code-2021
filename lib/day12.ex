defmodule Advent.Day12 do
  alias Advent.Day12.Path

  def load_puzzle(), do: Advent.read("data/day12.txt")

  def part1() do
    load_puzzle()
    |> count_paths()
  end

  def part2() do
    load_puzzle()
    |> count_paths(2)
  end

  def count_paths(lines, small_limit \\ 1) do
    parse(lines)
    |> search([Path.new()], [], small_limit)
    |> length()
  end

  def parse(lines) do
    Enum.reduce(lines, %{}, fn line, map ->
      [src | [dest]] = String.split(line, "-")

      Map.update(map, src, [dest], &[dest | &1])
      |> Map.update(dest, [src], &[src | &1])
    end)
  end

  def search(_, [], paths, _), do: paths

  def search(graph, frontier, paths, small_limit) do
    {complete, next_frontier} =
      Enum.flat_map(frontier, &expand(graph, &1, small_limit))
      |> Enum.split_with(&Path.complete?/1)

    search(graph, next_frontier, paths ++ complete, small_limit)
  end

  def expand(graph, path, small_limit) do
    Map.get(graph, Path.last(path))
    |> Enum.filter(&Path.visitable?(path, &1, small_limit))
    |> Enum.map(&Path.visit(path, &1))
  end
end

defmodule Advent.Day12.Path do
  defstruct [:caves, :small]

  alias __MODULE__, as: Path

  def new() do
    %Path{caves: ["start"], small: %{"start" => 1}}
  end

  def visitable?(%Path{small: small}, cave, small_limit) do
    cond do
      cave == "start" ->
        false

      small?(cave) ->
        Map.get(small, cave, 0) == 0 or
          Enum.find(small, nil, fn {_, count} -> count == small_limit end) == nil

      true ->
        true
    end
  end

  def last(%Path{caves: [cave | _]}), do: cave

  def complete?(path), do: last(path) == "end"

  def visit(%Path{caves: caves, small: small}, cave) do
    caves = [cave | caves]
    small = if small?(cave), do: Map.update(small, cave, 1, &(&1 + 1)), else: small
    %Path{caves: caves, small: small}
  end

  defp small?(cave), do: String.downcase(cave) == cave
end
