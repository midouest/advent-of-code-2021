# Day 3

## Part 1

My first thought upon reading the description was that I would need to make use of Elixir's `Bitwise` module to decode and manipulate the input.

The first mistake I made was that I defined my unit tests in terms of an array of integers. The right solution might have been more obvious to me if I had defined the tests in terms of a list of strings. By writing tests on a list of integers, I spent quite a bit of time solving the problem using `Bitwise.<<</2` and `Bitwise.&&&/2`. I had to completely rewrite my solution when I attempted to tackle the real puzzle input.

It ended up being much simpler to use `String.graphemes/1` to break each line up into characters and then convert them to `1` or `0` using `String.to_integer/1`.

I used the following approach to find the gamma rate:

1. Count the number of ones in each column
2. Select 1 for a column if the number of 1s is greater than half the input length, otherwise 0
3. Convert the list of bits to an integer

To count the number of ones, I used `Enum.reduce/2` with no accumulator so that the first element was used as the accumulator. The reducer uses `Enum.zip_with/3` with `+/2` as the zipper to add each list of bits together.

```elixir
counts =
  parse_lines(lines)
  |> Enum.reduce(fn bits, counts -> Enum.zip_with(bits, counts, &+/2) end)
```

For part 2, I was expecting to find a built-in function to convert a boolean value to one or zero. It turns out that Elixir has no such function. However, you can use an `if..else` expression on a single line to create one:

```elixir
if bool, do: 1, else: 0 end
```

I discovered `Integer.undigits/2` which allowed me to convert a list of bits into a base-10 integer. There's also a corresponding `Integer.digits/2` which goes in the other direction.

```elixir
gamma =
  Enum.map(counts, &if(&1 > length(lines) / 2, do: 1, else: 0))
  |> Integer.undigits(2)
```

If the gamma rate is the most common bit in each column, and a bit can only be one or zero, then the epsilon rate is the inverse of the bit in each column of the gamma rate.

I initially attempted to use `Bitwise.bnot/1` on the gamma rate to compute the epsilon. I was surprised when the result of `Bitwise.bnot(22)` was `-23`. Then I remembered that `bnot` doesn't flip each bit but rather flips the sign bit. What I really wanted was to bitwise exclusive-or the gamma rate with a number that would have one in each bit. To find this number, I took two to the power of the number of bits in the gamma rate and subtracted one.

```elixir
num_digits = String.length(List.first(lines))
epsilon = Bitwise.bxor(gamma, Integer.pow(2, num_digits) - 1)
```

## Part 2

I wasted a significant amount of time on part 2 by not reading the problem description carefully.

My initial understanding was that I needed to find the element in the input that had the longest sub-match starting at the beginning with the gamma and epsilon rates for the O2 and CO2 ratings, respectively.

I implemented this by doing a single pass for each rate to find the element with the longest match. The unit tests immediately indicated that I had made a mistake.

After re-reading the problem description, I realized that there was no getting around making multiple passes over the input set. However, each pass would reduce the set of elements I would need to compare against.

I also noticed that the rejected set of elements for the first pass of the O2 rating was the initial set of elements for the first pass of the CO2 rating. This lead me down another dead end of trying to compute both the O2 and CO2 ratings recursively within the a single function.

After many false starts, the best approach was to decode the O2 and CO2 ratings separately. However, I made the solution more general by parameterizing the decoding function to accept a predict that selected whether to take the most or least common elements from each pass.

```elixir

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
```

## I Learned

- To write my unit tests in terms of the actual input (a list of strings)
- To read the problem description carefully
- `Bitwise` module
- `String.graphemes/1`
- `Enum.zip_with/3`
- Elixir does not have a boolean-to-integer cast
- `Integer.digits/2` and `Integer.undigits/2`
- `Integer.pow/2` (`**` is available in Elixir 1.13+, but I am on Elixir 1.12)
- `Enum.split_with/2`
- Calling function variables (`fun.(arg)`)
- Matching a list with one item (`[val]` or `[val | []]`)
- `Bitwise.bnot/1` and `Bitwise.bxor/2`
