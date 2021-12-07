# Day 7

## Part 1

My first thought for part 1 was to brute force the solution by finding the
minimum distance for every possible position. This would require iterating over
all input positions (1000) for every possible position (~2000). That's on the
order of 2000000 iterations which is well within brute force territory. The
solution computed in ~100ms.

## Part 2

The brute force for part 2 would require anoter 2000 or so iterations for any
given position in the worst case to compute the consecutive sum. I remembered
that there was a simple formula for computing this in constant time:

```
n * (n + 1) / 2
```

I extended my solve function to accept a second argument that augmented the cost
function. The part 1 solution passed `&Function.identity/1`, whereas the part 2
solution passed the consecutive sum function. The solution computed in ~100ms.

## Reddit

It looks like I could have solved part 1 by just computing the median of the
input. The median of a list of numbers minimizes the sum of the absolute
distance of all numbers in the list.
