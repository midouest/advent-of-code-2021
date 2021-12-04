# Advent

Solutions to [Advent of Code 2021](https://adventofcode.com/2021) in Elixir

## Project Structure

```
.
├── blog
│   ├── dayXX.md  # Solution postmortem
│   │   ...
│
├── data
│   ├── dayXX.txt  # Puzzle input
│   │   ...
│
├── lib
│   ├── advent.ex  # Prelude module with common code
│   ├── dayXX.ex   # Puzzle solution
│   │   ...
│
└── test
    ├── dayXX_test.exs  # Puzzle example unit tests
    │   ...
```

## Dependencies

**Required**

- [Elixir](https://elixir-lang.org)

**Recommended**

- [Visual Studio Code](https://code.visualstudio.com)

## Usage

### Interactive

```shell
$ iex -S mix

iex(1)> import Advent.Day01
Advent.Day01
iex(2)> part1()
1266
iex(3)> part2()
1217
iex(4)> recompile
Compiling 1 file (.ex)
:ok
```

### Run Tests

Run tests on the example data sets given in the puzzles.

```shell
$ mix test
........

Finished in 0.05 seconds (0.00s async, 0.05s sync)
8 tests, 0 failures

Randomized with seed 16181
```
