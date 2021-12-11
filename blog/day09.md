# Day 9

## Part 1

I computed the local minima by iterating over every cell in the grid and filtering out the ones that were not smaller than all their neighbors.

```elixir
defp local_min(grid) do
  grid
  |> Grid.coords()
  |> Enum.reduce([], fn {coord, height}, minima ->
    min =
      Grid.neighbors(grid, coord)
      |> Enum.map(&Grid.fetch!(grid, &1))
      |> Enum.reduce(nil, &min(&1, &2))

    if height < min do
      [{coord, height} | minima]
    else
      minima
    end
  end)
end
```

In hindsight, I could have implemented this with `Enum.filter` instead of `Enum.reduce`. I only returned the height of the local minima for my initial part 1 solution, but I modified it to return both the coordinate and height to make it reusable for part 2.

## Part 2

I used a flood-fill algorithm to solve part 2. Starting from each local minimum calculated in part 1, I created an initial basin set using the minimum coordinate.

```elixir
defp find_basin(coord, grid) do
  frontier = [coord]
  basin = MapSet.new(frontier)

  expand_basin(frontier, basin, grid)
end
```

I then wrote a recursive function to expand the basin by all neighbors of the cells in the frontier. I filtered out neighbors that were already in the basin or whose height was equal to `9`.

```elixir
defp expand_basin([], basin, _), do: basin

defp expand_basin([coord | frontier], basin, grid) do
  neighbors =
    Grid.neighbors(grid, coord)
    |> Enum.filter(fn coord ->
      not MapSet.member?(basin, coord) and Grid.fetch!(grid, coord) != 9
    end)

  frontier = frontier ++ neighbors
  basin = MapSet.union(basin, MapSet.new(neighbors))

  expand_basin(frontier, basin, grid)
end
```
