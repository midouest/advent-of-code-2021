defmodule Advent.Day12 do
  alias Advent.Day12.Path

  def load_puzzle(), do: Advent.read("data/day12.txt")

  def part1() do
    load_puzzle()
    |> count_paths()
  end

  def part2() do
    load_puzzle()
  end

  def count_paths(lines) do
    parse(lines)
    |> search([Path.new()], [])
    |> length()
  end

  def parse(lines) do
    Enum.reduce(lines, %{}, fn line, map ->
      [src | [dest]] = String.split(line, "-")

      Map.update(map, src, [dest], &[dest | &1])
      |> Map.update(dest, [src], &[src | &1])
    end)
  end

  def search(_, [], paths), do: paths

  def search(graph, frontier, paths) do
    {complete, next_frontier} =
      Enum.flat_map(frontier, &expand(graph, &1))
      |> Enum.split_with(&Path.complete?/1)

    search(graph, next_frontier, paths ++ complete)
  end

  def expand(graph, path) do
    Map.get(graph, Path.last(path))
    |> Enum.filter(&Path.visitable?(path, &1))
    |> Enum.map(&Path.visit(path, &1))
  end
end

defmodule Advent.Day12.Path do
  defstruct [:caves, :small]

  alias __MODULE__, as: Path

  def new() do
    %Path{caves: ["start"], small: MapSet.new(["start"])}
  end

  def visitable?(%Path{small: small}, cave) do
    if small?(cave) do
      not MapSet.member?(small, cave)
    else
      true
    end
  end

  def last(%Path{caves: [cave | _]}), do: cave

  def complete?(path), do: last(path) == "end"

  def visit(%Path{caves: caves, small: small}, cave) do
    caves = [cave | caves]
    small = if small?(cave), do: MapSet.put(small, cave), else: small
    %Path{caves: caves, small: small}
  end

  defp small?(cave), do: String.downcase(cave) == cave
end
