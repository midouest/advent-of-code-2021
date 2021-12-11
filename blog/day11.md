# Day 11

## Part 1

I started by creating a new `Grid` module within the `Advent.Day11` module. The `neighbors` function for this grid returned both cardinal _and_ diagonal neighbors. I considered putting it in the top-level `Advent` module since it's likely that so many solutions will have a 2D grid.

I tried to be clever when computing `neighbors` by using a for-comprehension. In order to make sure that I rejected the `{0, 0}` coordinate, I added a `dx != 0 or dy != 0` filter to the comprehension. After looking at some other solutions, I could have simplified this by doing `{dx, dy} != {0, 0}`.

```elixir
def neighbors(%Grid{size: {width, height}}, {row, col}) do
  for dx <- [-1, 0, 1],
      dy <- [-1, 0, 1],
      dx != 0 or dy != 0 do
    {row + dy, col + dx}
  end
  |> Enum.filter(fn {row, col} ->
    row >= 0 and row < height and col >= 0 and col < width
  end)
end
```

Implementing the logic for computing each iteration got messy fast. I first did a single pass over the entire grid and incremented the value of each cell. If a cell's value was greater than `9`, I stored its coordinates in a `MapSet` of triggered cells for the next phase. I could have used a `List` to track triggered coordinates for this phase because I was not considering neighbors yet. I eventually found that I could use the same function to increment cell values for the initial pass as I use when I'm computing the effect of a flash on a cell's neighbors. It was easier to use `MapSets` in both places for consistency.

```elixir
def increase_energy({coord, value}, {map, triggered}) do
  next_value = value + 1
  map = Map.put(map, coord, next_value)

  triggered =
    if next_value > 9 do
      MapSet.put(triggered, coord)
    else
      triggered
    end

  {map, triggered}
end
```

I created a recursive function to calculate the effective of each flash spreading across the grid. The function took a grid, a list of coordinates to be triggered, and a running total of flashes recorded this step. I started by defining the stop case: if the list of coordinates to be triggered is empty, return a tuple of the grid and the total flashes.

```elixir
def flash(grid, [], flashes), do: {grid, flashes}
```

Next I defined the recursive case. For each cell that is firing, I first set its value to `0`. Then I iterated over all of its neighbors that are non-zero and increased their energy level. This lead to an incorrect solution (too high). Eventually I realized that I was accidentally including cells that were going to fire later in the iteration cycle. I solved this by creating a `MapSet` from the initial list of cells to trigger and then filtered out any coordinates that were in the firing set.

In hindsight, I think I could have done a better job breaking this solution down into smaller functions. I also got lazy with naming and had lots of name collisions. This made it a little difficult to read as things got more complex.

```elixir
def flash(%Grid{map: map} = grid, frontier, flashes) do
  prev_frontier = MapSet.new(frontier)

  {map, frontier, flashes} =
    Enum.reduce(frontier, {map, MapSet.new(), flashes}, fn coord,
                                                        {map, next_frontier, flashes} ->
      map = Map.put(map, coord, 0)

      {map, next_frontier} =
        neighbors(grid, coord)
        |> Enum.map(fn coord -> {coord, Map.get(map, coord)} end)
        |> Enum.reject(fn {coord, value} ->
          MapSet.member?(prev_frontier, coord) or value == 0
        end)
        |> Enum.reduce({map, next_frontier}, &increase_energy/2)

      {map, next_frontier, flashes + 1}
    end)

  flash(%Grid{grid | map: map}, MapSet.to_list(frontier), flashes)
end
```

## Part 2

I first added a `Grid.area` function which would tell me how many total cells were in the grid. My strategy was to compare the number of fired cells in each step with the total area of the `Grid` and stop iteration if they were equal. The only other modification I had to make was to return both the grid state and the number of flashes from `flash/3`. Finally I used `Stream.iterate` and `Enum.reduce_while` to increment the grid a single step at a time and check the number of flashes. I could have implemented this process as a recursive function, but I was getting tired of defining new functions!
