defmodule Advent.Day14 do
  def load_puzzle(), do: Advent.read("data/day14.txt")

  def part1() do
    load_puzzle()
    |> most_least_difference()
  end

  def part2() do
    load_puzzle()
  end

  def most_least_difference(lines) do
    {template, rules} = parse(lines)

    [least | rest] =
      process(template, rules, 10)
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort()

    most = List.last(rest)

    most - least
  end

  def parse(lines) do
    [template | ["" | rules]] = lines

    template = String.graphemes(template)

    rules =
      rules
      |> Enum.map(fn rule -> String.split(rule, " -> ") |> List.to_tuple() end)
      |> Enum.reduce(%{}, fn {pair, insert}, map ->
        Map.put(map, String.graphemes(pair), insert)
      end)

    {template, rules}
  end

  def process(template, _, 0), do: template
  def process(template, rules, n), do: process(step(template, rules), rules, n - 1)

  def step(template, rules) do
    template
    |> Enum.chunk_every(2, 1)
    |> Enum.reduce([], fn
      [first], output ->
        output ++ [first]

      [first | _] = pair, output ->
        case Map.get(rules, pair) do
          nil -> output ++ [first]
          insert -> output ++ [first, insert]
        end
    end)
  end
end
