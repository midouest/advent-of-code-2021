defmodule Advent.Day22 do
  alias Advent.Day22.Step
  alias Advent.Day22.Box

  def load_puzzle(), do: Advent.read("data/day22.txt")

  def part1() do
    load_puzzle()
    |> count_on()
  end

  def part2() do
    load_puzzle()
    |> count_on(nil)
  end

  def count_on(lines, area \\ Box.new(-50..50, -50..50, -50..50)) do
    lines
    |> Enum.map(&Step.parse/1)
    |> Enum.filter(fn step ->
      area == nil or Box.contains?(area, step.box)
    end)
    |> Enum.reduce([], fn step, signed_boxes ->
      new_signed_boxes =
        signed_boxes
        |> Enum.filter(fn {_, box} -> Box.intersects?(step.box, box) end)
        |> Enum.map(fn {sign, box} -> {-sign, Box.intersection(step.box, box)} end)

      signed_boxes = signed_boxes ++ new_signed_boxes

      if step.on? do
        [{1, step.box} | signed_boxes]
      else
        signed_boxes
      end
    end)
    |> Enum.reduce(0, fn {sign, box}, total ->
      total + sign * Box.volume(box)
    end)
  end
end

defmodule Advent.Day22.Step do
  defstruct on?: false, box: nil

  alias __MODULE__, as: Step
  alias Advent.Day22.Box

  @re ~r"^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$"

  def parse(line) do
    [state | rest] = Regex.run(@re, line, capture: :all_but_first)

    on? =
      case state do
        "on" -> true
        "off" -> false
      end

    [x, y, z] =
      rest
      |> Enum.chunk_every(2)
      |> Enum.map(fn [left, right] ->
        String.to_integer(left)..String.to_integer(right)//1
      end)

    box = Box.new(x, y, z)
    %Step{on?: on?, box: box}
  end
end

defmodule Advent.Day22.Box do
  defstruct x: 0..-1//1, y: 0..-1//1, z: 0..-1//1

  alias __MODULE__, as: Box

  def new(_.._//1 = x, _.._//1 = y, _.._//1 = z) do
    %Box{x: x, y: y, z: z}
  end

  def volume(%Box{x: x, y: y, z: z}) do
    Range.size(x) * Range.size(y) * Range.size(z)
  end

  def intersects?(%Box{} = b1, %Box{} = b2) do
    not disjoint?(b1, b2)
  end

  def disjoint?(%Box{x: x1, y: y1, z: z1}, %Box{x: x2, y: y2, z: z2}) do
    Range.disjoint?(x1, x2) or Range.disjoint?(y1, y2) or Range.disjoint?(z1, z2)
  end

  def intersection(%Box{x: x1, y: y1, z: z1}, %Box{x: x2, y: y2, z: z2}) do
    x = max(x1.first, x2.first)..min(x1.last, x2.last)//1
    y = max(y1.first, y2.first)..min(y1.last, y2.last)//1
    z = max(z1.first, z2.first)..min(z1.last, z2.last)//1
    new(x, y, z)
  end

  def contains?(%Box{x: x1, y: y1, z: z1}, %Box{x: x2, y: y2, z: z2}) do
    x2.first >= x1.first and x2.last <= x1.last and
      y2.first >= y1.first and y2.last <= y1.last and
      z2.first >= z1.first and z2.last <= z1.last
  end
end
