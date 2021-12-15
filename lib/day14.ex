defmodule Advent.Day14 do
  def load_puzzle(), do: Advent.read("data/day14.txt")

  def part1() do
    load_puzzle()
    |> most_least_difference(10)
  end

  def part2() do
    load_puzzle()
    |> most_least_difference(40)
  end

  def most_least_difference(lines, steps) do
    {chars, pairs, rules} = parse(lines)

    counts =
      process(chars, pairs, rules, steps)
      |> Map.values()
      |> Enum.sort()

    least = List.first(counts)
    most = List.last(counts)

    most - least
  end

  def parse(lines) do
    [template | ["" | rules]] = lines
    graphemes = String.graphemes(template)
    chars = Enum.frequencies(graphemes)

    pairs =
      graphemes
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(%{}, fn pair, map ->
        Map.update(map, Enum.join(pair), 1, &(&1 + 1))
      end)

    rules =
      rules
      |> Enum.map(fn rule -> String.split(rule, " -> ") end)
      |> Enum.reduce(%{}, fn [pair, insert], map ->
        [left, right] = String.graphemes(pair)
        Map.put(map, pair, {insert, [left <> insert, insert <> right]})
      end)

    {chars, pairs, rules}
  end

  def process(chars, _, _, 0), do: chars

  def process(chars, pairs, rules, n) do
    {chars, pairs} = step(chars, pairs, rules)
    process(chars, pairs, rules, n - 1)
  end

  def step(chars, pairs, rules) do
    Enum.reduce(pairs, {chars, %{}}, fn {pair, count}, {chars, pairs} ->
      {char, products} = Map.get(rules, pair)
      chars = Map.update(chars, char, count, &(&1 + count))

      pairs =
        Enum.reduce(products, pairs, fn product, pairs ->
          Map.update(pairs, product, count, &(&1 + count))
        end)

      {chars, pairs}
    end)
  end
end
