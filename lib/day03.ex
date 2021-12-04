defmodule Advent.Day03 do
  def load_puzzle(), do: Advent.read("data/day03.txt")

  def part1() do
    load_puzzle()
    |> decode_power()
  end

  def part2() do
    load_puzzle()
    |> decode_life_support()
  end

  def parse_lines(lines) do
    Stream.map(lines, fn line ->
      String.graphemes(line)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def decode_power(lines) do
    counts =
      parse_lines(lines)
      |> Enum.reduce(fn bits, counts -> Enum.zip_with(bits, counts, &+/2) end)

    gamma =
      Enum.map(counts, &if(&1 > length(lines) / 2, do: 1, else: 0))
      |> Integer.undigits(2)

    num_digits = String.length(List.first(lines))
    epsilon = Bitwise.bxor(gamma, 2 ** num_digits - 1)

    gamma * epsilon
  end

  def decode_life_support(lines) do
    nums = parse_lines(lines)
    o2 = filter_pos_freq(nums, 0, &>=/2)
    co2 = filter_pos_freq(nums, 0, &</2)

    o2 * co2
  end

  def filter_pos_freq([num], _, _) do
    Integer.undigits(num, 2)
  end

  def filter_pos_freq(nums, index, criteria) do
    {ones, zeroes} = Enum.split_with(nums, &(Enum.at(&1, index) == 1))

    if criteria.(length(ones), length(zeroes)) do
      filter_pos_freq(ones, index + 1, criteria)
    else
      filter_pos_freq(zeroes, index + 1, criteria)
    end
  end
end
