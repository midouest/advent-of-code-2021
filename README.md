# Advent

Solutions to [Advent of Code 2021](https://adventofcode.com/2021) in Elixir

## Project Structure

- `blog`: Write-ups on each solution
- `data`: My puzzle input for each day
- `lib/advent.ex`: Prelude module with common code
- `lib/dayXX.ex`: Puzzle solution for a given day
- `test/dayXX_test.exs`: Unit tests for a given day

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
.........

Finished in 0.03 seconds (0.00s async, 0.03s sync)
9 tests, 0 failures
```
