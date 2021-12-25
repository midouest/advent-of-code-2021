defmodule Advent.Day25 do
  alias Advent.Day25.Seafloor

  def load_puzzle(), do: Advent.read("data/day25.txt")

  def part1() do
    load_puzzle()
    |> settle()
  end

  def part2() do
    raise("No part 2 on day 25!")
  end

  def settle(lines) do
    lines
    |> Seafloor.parse()
    |> Seafloor.run()
  end
end

defmodule Advent.Day25.Seafloor do
  defstruct order: [], herds: %{}, w: 0, h: 0

  alias __MODULE__, as: Seafloor

  def parse(lines) do
    h = length(lines)
    w = String.length(List.first(lines))

    {e, s} =
      lines
      |> Stream.map(fn line ->
        line
        |> String.graphemes()
        |> Enum.with_index()
      end)
      |> Stream.with_index()
      |> Enum.reduce({MapSet.new(), MapSet.new()}, fn {cols, y}, acc ->
        Enum.reduce(cols, acc, fn {value, x}, {e, s} = acc ->
          coord = {x, y}

          case value do
            ">" -> {MapSet.put(e, coord), s}
            "v" -> {e, MapSet.put(s, coord)}
            "." -> acc
          end
        end)
      end)

    order = [{1, 0}, {0, 1}]

    herds = %{
      {1, 0} => e,
      {0, 1} => s
    }

    %Seafloor{order: order, herds: herds, w: w, h: h}
  end

  def run(%Seafloor{} = s), do: run(s, 1)

  def run(%Seafloor{} = s, i) do
    {s, count} = step(s)

    if count == 0 do
      i
    else
      run(s, i + 1)
    end
  end

  def step(%Seafloor{} = s) do
    Enum.reduce(s.order, {s, 0}, fn dir, {s, total} ->
      herd = s.herds[dir]
      {herd, count} = step_herd(s, herd, dir)
      herds = Map.put(s.herds, dir, herd)
      {%Seafloor{s | herds: herds}, total + count}
    end)
  end

  def step_herd(%Seafloor{} = s, herd, dir) do
    Enum.reduce(herd, {MapSet.new(), 0}, fn prev, {next_herd, count} ->
      next = next_coord(s, prev, dir)
      {final, count} = if empty?(s, next), do: {next, count + 1}, else: {prev, count}
      {MapSet.put(next_herd, final), count}
    end)
  end

  def empty?(%Seafloor{} = s, coord) do
    Enum.all?(s.herds, fn {_, herd} -> not MapSet.member?(herd, coord) end)
  end

  def next_coord(%Seafloor{} = s, {x0, y0}, {dx, dy}) do
    x1 = Integer.mod(x0 + dx, s.w)
    y1 = Integer.mod(y0 + dy, s.h)
    {x1, y1}
  end
end
