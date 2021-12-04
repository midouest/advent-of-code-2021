# Day 2

## Part 1

The overall solution for part 1 was apparent from the problem description:

1. Parse each line into a direction and magnitude
2. Use a reducer to evaluate each direction/magnitude tuple and produce the next state

To parse each line, I used `String.split/2` to separate the command from the direction. Then I used `Integer.parse/1` to convert the direction to an integer. This was kind of awkward since I had to destructure the result of `Integer.parse/1` to get the value I was interested. I discovered `String.to_integer/1` while solving day 3's puzzle.

```elixir
def parse(line) do
  [direction, delta_str] = String.split(line, " ")
  delta = String.to_integer(delta_str)
  {direction, delta}
end
```

I used function overloading and pattern matching to handle each direction in the command.

```elixir
def exec({"forward", d}, {x, y, a}), do: {x + d, y, a}
def exec({"up", d}, {x, y, a}), do: {x, y - d, a}
def exec({"down", d}, {x, y, a}), do: {x, y + d, a}
```

## Part 2

My first thought after reading the description for part 2 was that I needed to abstract the logic for evaluating commands. I started by creating two submodules that implemented command evaluation for each part of the puzzle. I also updated the `pilot` command from part 1 to accept a function reference to be executed in the reducer. I quickly realized that both parts of the puzzle would need to operator on a tuple of `x`, `y` and `aim`. In hindsight, I could have further abstracted the implementations to return the initial state of the reducer and the logic for computing the solution.

I originally had the `Part1` and `Part2` modules nested within the `Advent.Day02` module. I was surprised when I learned I couldn't refer to the nested submodules
without an `alias`. It turns out that Elixir modules must be referenced by their
fully qualified names regardless of if they're nested or not.

```elixir
defmodule Part1 do
  def exec({"forward", d}, {x, y, a}), do: {x + d, y, a}
  def exec({"up", d}, {x, y, a}), do: {x, y - d, a}
  def exec({"down", d}, {x, y, a}), do: {x, y + d, a}
end

defmodule Part2 do
  def exec({"forward", d}, {x, y, a}), do: {x + d, y + a * d, a}
  def exec({"up", d}, {x, y, a}), do: {x, y, a - d}
  def exec({"down", d}, {x, y, a}), do: {x, y, a + d}
end

alias Advent.Day02.{Part1, Part2}

def part1() do
  load_input()
  |> pilot(&Part1.exec/2)
end

def part2() do
  load_input()
  |> pilot(&Part2.exec/2)
end

def pilot(commands, exec) do
  {x, y, _} =
    commands
    |> Stream.map(&parse/1)
    |> Enum.reduce({0, 0, 0}, exec)

  x * y
end
```

I moved the `Part1` and `Part2` `exec` functions into the parent module and gave them unique names in order to reduce the line count of the solution.

## Reddit

I was surprised to learn that both part 1 and part 2 could be solved in a single pass by treating the `aim` variable as the value of `y` for part 1.

## I Learned

- Elixir modules and nesting
- `alias`
- `Integer.parse/2`
- Function overloading and pattern matching
