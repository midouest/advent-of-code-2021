# Day 9

## Part 1

Ideas

- A point is a low or high point if it is lower or higher than all adjacent neighbors
- Naive
  - One pass to load all coordinates into grid (map)
  - For each coordinate, check all 4 neighbors for lowest and highest
- Other solutions
  - Algorithm for finding local max and min in a 2d grid?

## Part 2

Flood fill from local minima
