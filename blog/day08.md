# Day 8

## Part 1

I initially started writing down heuristics for deriving the other six numbers. Then I re-read the problem and realized that I only needed to find the initial set of known signals (1, 4, 7 and 8) for part 1. I wrote a simple function to count the number of times the length of an output signal was one of the 4 known lengths.

```elixir
def count_1478({_, output}) do
  output
  |> Enum.reduce(0, fn signal, count ->
    len = String.length(signal)

    cond do
      len == 2 or len == 3 or len == 4 or len == 7 ->
        count + 1

      true ->
        count
    end
  end)
end
```

## Part 2

I started by writing down some heuristics for the other 6 numbers. I first grouped each number its total number of segments.

- 2 segments: 1
- 3 segments: 7
- 4 segments: 4
- 5 segments: 2, 3, 5
- 6 segments: 0, 6, 9
- 7 segments: 8

Next I chose some heuristics to determine each of the 5 and 6-segment numbers based on the initial set of 4 numbers.

**6-segment numbers**

- 4 will have 1 segment not in the set of segments in 0
- 6 will share 1 segment with the set of segments in 1
- After finding 0 and 6, 9 will be the last remaining 6-segment number

**5-segment numbers**

- 5 has every segment in 6 except one
- 3 has one segment not used by 5
- 2 has two segments not used by 5

I started by parsing each signal into a `MapSet` of its digits. The order of the digits in the signal is not important, so using a `MapSet` allows us to easily compare signals independent of order. I also grouped the input signals into buckets by their size.

```elixir
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

  signals = Enum.group_by(signals, &MapSet.size/1)

  {signals, output}
end
```

Next I wrote a function to solve for the 6 unknown signals. I used pattern matching to destructure the signal buckets into the 1, 4, 7, 8, five-segment and six-segment signals. Then I used `Enum.split_with/2` to progressively split the five- and six-segment buckets into known and unknown signals.

I defined a helper function, `intersection_size_equals/3`, to test that the size of the intersection between two sets was the given size. I then used this to define other heuristic functions to determine if a given signal matched one of the heuristics I sketched out above. For example:

```elixir
defp intersection_size_equals?(set, other, len) do
  set |> MapSet.intersection(other) |> MapSet.size() == len
end

defp contains_one?(set, one), do: intersection_size_equals?(set, one, 2)

defp six?(set, one), do: not contains_one?(set, one)
```

I ended up using slightly different heuristics than what I initially wrote down. I did this in part because I developed new heuristics while writing the implementation that affected which signals were most convenient to solve for first.

```elixir
{[three], five_segments} = Enum.split_with(five_segments, &contains_one?(&1, one))
{[six], six_segments} = Enum.split_with(six_segments, &six?(&1, one))
{[zero], [nine]} = Enum.split_with(six_segments, &zero?(&1, four))
{[five], [two]} = Enum.split_with(five_segments, &five?(&1, six))
```

Finally I could decode each line by creating a map of signals from the input and then using it to look up the numbers in the output.

```elixir
def decode_line(line) do
  {signals, output} = parse_line(line)
  map = map_signals(signals)

  output
  |> Enum.map(&Map.fetch!(map, &1))
  |> Integer.undigits()
end
```

I went back and re-implemented part 1 in terms of part 2, which ended up making things slower and a bit messier:

```elixir
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
```
