defmodule Advent.Day08 do
  def load_puzzle(), do: Advent.read("data/day08.txt")

  def part1() do
    load_puzzle()
  end

  def part2() do
    load_puzzle()
    |> sum_decoded()
  end

  def count_all_1478(lines) do
    set = MapSet.new([1, 4, 7, 8])

    lines
    |> decode()
    |> Enum.map(fn decoded ->
      decoded
      |> Integer.digits()
      |> Stream.filter(&MapSet.member?(set, &1))
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def sum_decoded(lines) do
    lines
    |> decode()
    |> Enum.sum()
  end

  def decode(lines), do: Enum.map(lines, &decode_line/1)

  def decode_line(line) do
    {signals, output} = parse_line(line)
    map = map_signals(signals)

    output
    |> Enum.map(&Map.fetch!(map, &1))
    |> Integer.undigits()
  end

  def parse_line(line) do
    {signals, output} =
      line
      |> String.splitter(" | ")
      |> Enum.map(fn signals ->
        signals
        |> String.split(" ")
        |> Stream.map(&String.graphemes/1)
        |> Enum.map(&MapSet.new/1)
      end)
      |> List.to_tuple()

    signals = Enum.sort(signals, &(MapSet.size(&1) <= MapSet.size(&2)))

    {signals, output}
  end

  def map_signals([one | [seven | [four | rest]]]) do
    {unknown, [eight]} = Enum.split(rest, 6)
    %{5 => five_segments, 6 => six_segments} = Enum.group_by(unknown, &MapSet.size/1)

    {[three], five_segments} = Enum.split_with(five_segments, &contains_one?(&1, one))
    {[six], six_segments} = Enum.split_with(six_segments, &six?(&1, one))

    {[zero], [nine]} = Enum.split_with(six_segments, &zero?(&1, four))
    {[five], [two]} = Enum.split_with(five_segments, &five?(&1, six))

    %{
      zero => 0,
      one => 1,
      two => 2,
      three => 3,
      four => 4,
      five => 5,
      six => 6,
      seven => 7,
      eight => 8,
      nine => 9
    }
  end

  defp intersection_size_equals?(set, other, len) do
    set |> MapSet.intersection(other) |> MapSet.size() == len
  end

  defp contains_one?(set, one), do: intersection_size_equals?(set, one, 2)
  defp six?(set, one), do: not contains_one?(set, one)
  defp zero?(set, four), do: intersection_size_equals?(set, four, 3)
  defp five?(set, six), do: intersection_size_equals?(set, six, 5)
end
