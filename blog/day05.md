# Day 5

## Part 1

My first thought was that there are two possible solutions to this problem:

The naive approach is to increment a counter for each cell on a grid that a line crosses through. We could then iterate over every cell and return the number of cells that have a count greater than one. The puzzle description hints at this approach. A simple optimization would be to use a sparse grid (i.e. a `Map`) to save on space and time (although that is making the assumption that the input is also sparse). In Elixir, we will probably end up using a `Map` either way because using a list of lists would be inefficient due to linear access time.

The other approach is to compare every line against every other line (the cartesian product) and compute the amount of overlap between them. This might not quite be correct though because we would need to consider multiple lines overlapping at any given point. Given the size of the input (500 lines and a 1000x1000 grid), this solution seems more complex.

Solving part 1 was straightforward and didn't require me to learn many new constructs. When it came to updating the count of lines crossing through a coordinate, I looked for a `Map` function that could retrieve the current value of a key and update it. I was immediately drawn to `Map.get_and_update/3` which seemed to do exactly what I wanted. The one weird thing is that the update function passed to `Map.get_and_update/3` must return a tuple of `{current, next}`, and `Map.get_and_update/3` itself returns a tuple of `{map, current}`. I later learned that `Map.get_and_update/3` is intended for simultaneously updating a value while returning its current value before updating. What I really wanted was `Map.update/4`, which accepts a default argument for when a key doesn't exist in the map.

## Part 2

I extended my solution for part 1 to solve part 2 by making a two changes:

1. When calculating the coordinates of a line, I replaced the `if..else` expression with a `cond`, added a third clause and used `Enum.zip_with` to construct the coordinates for diagonal lines.
2. I added a second argument to `count_overlap` that accepts a function to be passed to `Stream.filter/2` before marking lines in the grid. I gave this argument a default of `&Function.identity/` so that `count_overlap/1` counts all lines. The solution to part 1 now becomes `count_overlap(lines, &straight?/1)`.

## Reddit

I checked Reddit to see if anyone had a more elegant solution. I was surprised to find only solutions that tracked counts in a grid. I did see [one person](https://www.reddit.com/r/adventofcode/comments/r9hpfs/2021_day_5_bigger_vents/) proposing their own "upping the ante" problem that used a much larger grid with much larger vents. The vents in these problems are millions of cells long, so there's probably an efficient solution that doesn't track counts on a grid.

## I Learned

- `Map.get_and_update/3` and `Map.update/4`
- `cond` for `if..elseif` and how to set a default clause with `true ->`
- `Time.utc_now`, `Time.diff` and `:microseconds`
- `~s` sigils for interpolating variables in strings
- Default function arguments with `\\`
- `Function.identity/1`
- Mapping over maps operates on key-value tuples
- `Map.values()` is faster than `Stream.map(&elem(&1, 1))`
