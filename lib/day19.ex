defmodule Advent.Day19 do
  alias Advent.Day19.Scan

  def load_puzzle(), do: Advent.read("data/day19.txt")

  def part1() do
    load_puzzle()
    |> count_all_beacons()
  end

  def part2() do
    load_puzzle()
    |> largest_distance()
  end

  def count_all_beacons(lines) do
    scan = build_map(lines)
    length(scan.coords)
  end

  def largest_distance(lines) do
    lines
    |> build_map()
    |> Scan.largest_distance()
  end

  def build_map(lines) do
    lines
    |> Scan.parse()
    |> Scan.merge_all()
  end
end

defmodule Advent.Day19.Scan do
  defstruct id: nil, coords: [], vectors: %{}, others: %{}

  alias __MODULE__, as: S

  def parse(lines) do
    lines
    |> parse(%S{}, [])
    |> Enum.map(&calc_vectors/1)
  end

  def parse([], s, acc), do: acc ++ [s]
  def parse(["" | lines], s, acc), do: parse(lines, %S{}, acc ++ [s])

  def parse([line | lines], %S{coords: coords} = s, acc) do
    s =
      if String.starts_with?(line, "--") do
        id =
          line
          |> String.slice(12..-1)
          |> String.slice(0..-5)
          |> String.to_integer()

        %S{s | id: id}
      else
        coord =
          line
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
          |> List.to_tuple()

        %S{s | coords: coords ++ [coord]}
      end

    parse(lines, s, acc)
  end

  def calc_vectors(%S{coords: coords} = s) do
    vectors =
      for {coord0, a} <- coords |> Enum.with_index(),
          {coord1, b} <- coords |> Enum.with_index(),
          a != b,
          reduce: %{} do
        map ->
          vec = subtract(coord1, coord0)
          Map.put(map, vec, {a, b})
      end

    %S{s | vectors: vectors}
  end

  def add({x1, y1, z1}, {x0, y0, z0}), do: {x1 + x0, y1 + y0, z1 + z0}
  def subtract({x1, y1, z1}, {x0, y0, z0}), do: {x1 - x0, y1 - y0, z1 - z0}

  def manhattan({x1, y1, z1}, {x0, y0, z0}) do
    abs(x1 - x0) + abs(y1 - y0) + abs(z1 - z0)
  end

  def largest_distance(%S{others: others}) do
    coords = [{0, 0, 0} | Map.values(others)]

    for a <- coords,
        b <- coords,
        a != b,
        reduce: 0 do
      acc -> max(acc, manhattan(b, a))
    end
  end

  def merge_all([origin | scans]) do
    merge_all(scans, origin, all_rotations())
  end

  def merge_all([], origin, _), do: origin

  def merge_all([scan | scans], origin, rotations) do
    case merge(origin, scan, rotations) do
      %S{} = merged ->
        merge_all(scans, merged, rotations)

      nil ->
        merge_all(scans ++ [scan], origin, rotations)
    end
  end

  def merge(
        %S{id: id0, coords: coords0, others: others} = s0,
        %S{id: id1, coords: coords1} = s1,
        rotations
      ) do
    case find_rotation(s0, s1, rotations) do
      {rotation, mapping} ->
        {origin1_index, origin0_index} =
          mapping
          |> Map.to_list()
          |> hd()

        origin1 = Enum.at(coords1, origin1_index)
        origin0 = Enum.at(coords0, origin0_index)

        pos1 = reorient({0, 0, 0}, origin1, origin0, rotation)
        others = Map.put(others, id1, pos1)

        coords1 =
          coords1
          |> Enum.with_index()
          |> Enum.reject(fn {_, i} -> Map.has_key?(mapping, i) end)
          |> Enum.map(fn {coord, _} -> reorient(coord, origin1, origin0, rotation) end)

        coords0 = MapSet.new(coords0)
        coords1 = MapSet.new(coords1)

        coords =
          MapSet.union(coords0, coords1)
          |> MapSet.to_list()

        %S{id: id0, coords: coords, others: others}
        |> calc_vectors()

      _ ->
        nil
    end
  end

  def reorient(coord, origin1, origin0, rotation) do
    coord
    |> subtract(origin1)
    |> rotate(rotation)
    |> add(origin0)
  end

  def find_rotation(%S{vectors: v0}, %S{vectors: v1}, rotations) do
    v1_vecs = Enum.with_index(v1)

    Enum.find_value(rotations, fn rotation ->
      Enum.reduce_while(v1_vecs, %{}, fn {{vec, {a1, b1}}, i}, map ->
        cond do
          map_size(map) == 12 ->
            {:halt, {rotation, map}}

          map_size(v1) - i < 12 - map_size(map) ->
            {:halt, nil}

          true ->
            vec = rotate(vec, rotation)

            set =
              case Map.get(v0, vec) do
                {a0, b0} ->
                  map
                  |> Map.put(a1, a0)
                  |> Map.put(b1, b0)

                nil ->
                  map
              end

            {:cont, set}
        end
      end)
    end)
  end

  @angles [0, 90, 180, 270]

  def unique_rotations() do
    all_rotations()
    |> Enum.map(fn angle -> {rotate({1, 2, 3}, angle), angle} end)
    |> Enum.uniq_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
  end

  def all_rotations() do
    for x <- @angles,
        y <- @angles,
        z <- @angles do
      {x, y, z}
    end
  end

  def rotate(coord, {rx, ry, rz}) do
    coord
    |> rotate_x(rx)
    |> rotate_y(ry)
    |> rotate_z(rz)
  end

  def rotate_x({x, y, z}, 0), do: {x, y, z}
  def rotate_x({x, y, z}, 90), do: {x, -z, y}
  def rotate_x({x, y, z}, 180), do: {x, -y, -z}
  def rotate_x({x, y, z}, 270), do: {x, z, -y}

  def rotate_y({x, y, z}, 0), do: {x, y, z}
  def rotate_y({x, y, z}, 90), do: {z, y, -x}
  def rotate_y({x, y, z}, 180), do: {-x, y, -z}
  def rotate_y({x, y, z}, 270), do: {-z, y, x}

  def rotate_z({x, y, z}, 0), do: {x, y, z}
  def rotate_z({x, y, z}, 90), do: {-y, x, z}
  def rotate_z({x, y, z}, 180), do: {-x, -y, z}
  def rotate_z({x, y, z}, 270), do: {y, -x, z}
end
