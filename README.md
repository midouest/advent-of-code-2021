# Advent

Solutions to [Advent of Code 2021](https://adventofcode.com/2021) in [Elixir](https://elixir-lang.org) (1.13+)

## Project Structure

```
.
├── _template  # Generator task templates
│
├── blog
│   └── dayXX.md  # Solution postmortem
│
├── data
│   └── dayXX.txt  # Puzzle input
│
├── lib
│   ├── mix
│   │   └── tasks
│   │       └── advent.gen.ex  # Custom generator task
│   │
│   ├── advent.ex   # Prelude module with common code
│   ├── cli.ex      # Executable entrypoint
│   ├── dayXX.ex    # Puzzle solution
│   └── puzzles.ex  # Auto-generated list of solution modules
│
└── test
    └── dayXX_test.exs  # Puzzle example unit tests
```

## Usage

### Compiled

Use the `escript.build` task to compile the `advent` executable.

```shell
$ mix deps.get
All dependencies are up to date

$ mix escript.build
Compiling 1 file (.ex)
Generated escript advent with MIX_ENV=dev

$ ./advent help
./advent               # Solve all days
./advent <day>         # Solve only the given day (1-25)
./advent <day> <part>  # Solve only the given day and part (1-2)

$ ./advent 1
Day 01
------
Part 1 = 1266 (7.944 ms)
Part 2 = 1217 (4.207 ms)
```

### Interactive

Puzzles can be solved interactively using Elixir's interactive shell, `IEx`:

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

Run tests on the example data sets given in the puzzles using the `test` task:

```shell
$ mix test
........

Finished in 0.05 seconds (0.00s async, 0.05s sync)
8 tests, 0 failures

Randomized with seed 16181
```

### Generate

Generate files for each day using `mix advent.gen`:

```shell
$ mix advent.gen
* creating blog/day06.md
* creating data/day06.txt
* creating lib/day06.ex
* creating lib/puzzles.ex
* creating test/day06_test.exs
```

The `mix advent.gen` task can automatically fetch the puzzle input for the
next day. Create `config/secret.exs` with the following content:

```elixir
import Config

config :advent,
  token: ""
```

The `:token` environment variable must be set to a valid Advent of Code session
token.
