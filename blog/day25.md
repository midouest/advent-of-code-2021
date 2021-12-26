# Day 25

## Part 1

I parsed the east-moving and south-moving herds into two `MapSet`s so that I could update each one independently without having to iterate over the entire seafloor.

I stored these sets in a map with their direction vector as the key. When it became time to iterate over all the herds, I realized that `Map`s in Elixir do not guarantee the order of their keys. I decided to store a separate order array that I would iterate over instead.

## I Learned

- `Map` keys are not ordered
