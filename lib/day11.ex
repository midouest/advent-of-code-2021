defmodule Advent.Day11 do
  alias Advent.Day11.Grid

  def load_puzzle(), do: Advent.read("data/day11.txt")

  def part1() do
    load_puzzle()
    |> total_flashes()
  end

  def part2() do
    load_puzzle()
    |> first_sync_step()
  end

  def total_flashes(lines) do
    lines
    |> Grid.parse()
    |> Grid.tick(100, 0)
    |> elem(1)
  end

  def first_sync_step(lines) do
    grid = Grid.parse(lines)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(grid, fn i, grid ->
      {grid, flashes} = Grid.tick(grid, 1, 0)

      if flashes == Grid.area(grid) do
        {:halt, i}
      else
        {:cont, grid}
      end
    end)
  end
end

defmodule Advent.Day11.Grid do
  defstruct [:map, :size]

  alias __MODULE__, as: Grid

  def parse(lines) do
    height = length(lines)
    width = String.length(List.first(lines))

    map =
      lines
      |> Stream.map(fn line ->
        line
        |> String.graphemes()
        |> Stream.map(&String.to_integer/1)
        |> Enum.with_index()
      end)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {cols, row}, map ->
        Enum.reduce(cols, map, fn {value, col}, map ->
          Map.put(map, {row, col}, value)
        end)
      end)

    %Grid{map: map, size: {width, height}}
  end

  def tick(grid, 0, flashes), do: {grid, flashes}

  def tick(%Grid{map: map} = grid, iter, flashes) do
    {map, triggered} = Enum.reduce(map, {%{}, MapSet.new()}, &flash/2)
    {grid, flashes} = resolve(%Grid{grid | map: map}, MapSet.to_list(triggered), flashes)
    tick(grid, iter - 1, flashes)
  end

  def flash({coord, value}, {map, triggered}) do
    next_value = value + 1
    map = Map.put(map, coord, next_value)

    triggered =
      if next_value > 9 do
        MapSet.put(triggered, coord)
      else
        triggered
      end

    {map, triggered}
  end

  def resolve(grid, [], flashes), do: {grid, flashes}

  def resolve(%Grid{map: map} = grid, frontier, flashes) do
    prev_frontier = MapSet.new(frontier)

    {map, frontier, flashes} =
      Enum.reduce(frontier, {map, MapSet.new(), flashes}, fn coord,
                                                             {map, next_frontier, flashes} ->
        map = Map.put(map, coord, 0)

        {map, next_frontier} =
          neighbors(grid, coord)
          |> Enum.map(fn coord -> {coord, Map.get(map, coord)} end)
          |> Enum.reject(fn {coord, value} ->
            MapSet.member?(prev_frontier, coord) or value == 0
          end)
          |> Enum.reduce({map, next_frontier}, &flash/2)

        {map, next_frontier, flashes + 1}
      end)

    resolve(%Grid{grid | map: map}, MapSet.to_list(frontier), flashes)
  end

  def neighbors(%Grid{size: {width, height}}, {row, col}) do
    for dx <- [-1, 0, 1],
        dy <- [-1, 0, 1],
        dx != 0 or dy != 0 do
      {row + dy, col + dx}
    end
    |> Enum.filter(fn {row, col} ->
      row >= 0 and row < height and col >= 0 and col < width
    end)
  end

  def area(%Grid{size: {width, height}}), do: width * height
end
