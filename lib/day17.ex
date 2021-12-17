defmodule Advent.Day17 do
  alias Advent.Day17.Sim

  def load_puzzle(), do: Advent.read("data/day17.txt")

  def part1() do
    load_puzzle()
    |> highest_y_position()
  end

  def part2() do
    load_puzzle()
    |> possible_velocities()
  end

  def highest_y_position([line]) do
    parse(line)
    |> search()
    |> Enum.sort(&>=/2)
    |> List.first()
  end

  def possible_velocities([line]) do
    parse(line)
    |> search()
    |> Enum.count()
  end

  def search({{_, x_max}, {y_min, y_max}} = target) do
    Stream.flat_map(1..x_max, fn dx ->
      Stream.map(y_min..(2 * abs(y_max)), fn dy ->
        Sim.new({dx, dy}, target)
        |> Sim.fire()
      end)
      |> Stream.filter(fn {res, _} -> res == :hit end)
      |> Stream.map(fn {_, y_max} -> y_max end)
    end)
  end

  def parse(line) do
    String.slice(line, 13..String.length(line))
    |> String.split(", ")
    |> Enum.map(fn s ->
      String.slice(s, 2..String.length(s))
      |> String.split("..")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end
end

defmodule Advent.Day17.Sim do
  defstruct res: nil, pos: {0, 0}, y_max: 0, vel: nil, target: nil

  alias __MODULE__, as: S

  def new(vel, target), do: %S{vel: vel, target: target}

  def fire(%S{res: :hit, y_max: y_max}), do: {:hit, y_max}
  def fire(%S{res: :miss}), do: {:miss, nil}

  def fire(%S{res: nil} = sim) do
    sim
    |> step()
    |> check()
    |> fire()
  end

  def step(%S{pos: {x, y}, y_max: y_max, vel: {dx, dy}} = sim) do
    x = x + dx
    y = y + dy
    y_max = max(y_max, y)
    dx = dx - sign(dx)
    dy = dy - 1
    %S{sim | pos: {x, y}, y_max: y_max, vel: {dx, dy}}
  end

  def check(%S{} = sim) do
    res =
      cond do
        hit?(sim) ->
          :hit

        miss?(sim) ->
          :miss

        true ->
          nil
      end

    %S{sim | res: res}
  end

  def hit?(%S{pos: {x, y}, target: {{x_min, x_max}, {y_min, y_max}}}) do
    x >= x_min and x <= x_max and y >= y_min and y <= y_max
  end

  def miss?(%S{pos: {x, y}, target: {{_, x_max}, {y_min, _}}}) do
    x > x_max or y < y_min
  end

  def sign(0), do: 0
  def sign(x) when x > 0, do: 1
  def sign(_), do: -1
end
