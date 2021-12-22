defmodule Advent.Day22 do
  def load_puzzle(), do: Advent.read("data/day22.txt")

  def part1() do
    load_puzzle()
    |> count_on()
  end

  def part2() do
    load_puzzle()
  end

  def count_on(lines) do
    lines
    |> parse()
    |> reduce()
    |> MapSet.size()
  end

  @re ~r"^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$"

  def parse(lines) do
    lines
    |> Enum.map(fn line ->
      [state | rest] = Regex.run(@re, line, capture: :all_but_first)

      on? =
        case state do
          "on" -> true
          "off" -> false
        end

      ranges =
        rest
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()

      Tuple.insert_at(ranges, 0, on?)
    end)
  end

  def reduce(steps) do
    Enum.reduce(steps, MapSet.new(), &eval_step/2)
  end

  def eval_step({on?, x0, x1, y0, y1, z0, z1}, set) do
    with {x0, x1} <- overlap(x0, x1),
         {y0, y1} <- overlap(y0, y1),
         {z0, z1} <- overlap(z0, z1) do
      for x <- x0..x1, y <- y0..y1, z <- z0..z1, reduce: set do
        set ->
          coord = {x, y, z}
          if on?, do: MapSet.put(set, coord), else: MapSet.delete(set, coord)
      end
    else
      _ ->
        set
    end
  end

  def overlap(a0, a1) do
    if a0 > 50 or a1 < -50 do
      nil
    else
      {max(a0, -50), min(a1, 50)}
    end
  end
end
