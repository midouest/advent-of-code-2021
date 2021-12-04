# Day 1

## Python

I originally intended to solve this year's puzzles in Python. My goal was to complete all 25 days of the advent calendar, which I have never done before.

For the past two years I have used Rust, which is strict and verbose in addition to being a language I don't know well. This usually results in me taking a long time to solve problems, falling behind and burning out. In 2020, I also attempted to up the ante by creating visualizations of each solution.

On the other hand, I have used Python professionally for many years. The psuedocode that I sometimes write to think about my solutions is often valid Python. These two traits made Python an attractive choice to minimize the amount of time spent solving puzzles.

### Part 1

I chose to use a for-loop and a two variables to store the running count and previous depth. A more succinct solution could use `zip` and `functools.reduce` (which I forgot exists). I fell into the trap of premature optimization.

```python
#!/usr/bin/env python3

from typing import Iterable

from common.puzzle import parse_input, transform_line


def count_increases(depths: Iterable[int]) -> int:
    prev_depth = None
    count = 0
    for depth in depths:
        if prev_depth is not None and depth > prev_depth:
            count += 1
        prev_depth = depth
    return count


def main() -> None:
    depths = parse_input(transform_line(int))
    count = count_increases(depths)
    print(count)


if __name__ == "__main__":
    main()
```

### Part 2

Previous years have featured problems that involve calculating running sums over large inputs. A common optimization for these problems is to compute the next sum by subtracting the value that leaves the window and add the value that enters the window.

For today's problem, the window size is three, which does not save us any cycles compared to just summing the entire window. I also used a `deque` to get `O(1)` push/pop at the head and tail of the window.

```python
#!/usr/bin/env python3

from typing import Iterable
from collections import deque

from common.puzzle import parse_input, transform_line


def count_window_increases(depths: Iterable[int]) -> int:
    window: deque[int] = deque()
    window_sum = 0
    count = 0
    for depth in depths:
        if len(window) < 3:
            window_sum += depth
            window.append(depth)
            continue

        prev_sum = window_sum
        window_sum = prev_sum + depth - window.popleft()
        window.append(depth)
        if window_sum > prev_sum:
            count += 1

    return count


def main() -> None:
    depths = parse_input(transform_line(int))
    count = count_window_increases(depths)
    print(count)


if __name__ == "__main__":
    main()
```

## Elixir

I got bored of Python after one day and decided I wanted to use this year to learn a new language after all. I made the switch to Elixir on day 2. I revisited my day 1 solution before completing day 2.

I realized that part 2 of day 1 is a generalization of part 1 (as is often the case with Advent of Code puzzles). Both parts involve sums of sliding windows, but the window size in part 1 just happens to be 1.

I looked for a sliding or rolling window function in Elixir but didn't find anything initially. `Enum.chunk_every/2` looked promising, but at first glance it seemed like it always moved in increments of the chunk size. I needed chunks to overlap.

After some Googling, I learned that there is also `Enum.chunk_every/4`, which takes two extra arguments: a step size to increment each chunk by, and a flag to determine how to treat incomplete chunks. With these features, the general solution to both parts became clear:

1. Group depths into overlapping windows
2. Sum each window
3. Group sums into overlapping tuples of two elements
4. Count every time that the second element is greater than the first

The Elixir solution mapped 1:1 to these steps:

```elixir
def count_increasing(depths, size) do
  depths
    |> Stream.chunk_every(size, 1, :discard)
    |> Stream.map(&Enum.sum/1)
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.count(fn [prev, next] -> next > prev end)
end
```

The `Stream` module was used instead of `Enum` for all intermediate steps in order to avoid creating intermediate lists.

## I Learned

- `Enum` and `Stream` modules
- `File.open/2` and `IO.stream/2`
- `Stream.chunk_every/2` and `Stream.chunk_every/4`
- `Enum.count/2`
