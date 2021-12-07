# Day 6

## Part 1

I took the brute force approach:

1. Model the problem as a list of integers which represent the age of each fish
2. On each day, decrement each element in the list that is greater than 0
3. For each 0, reset its value to 6 and append an 8 to the end of the list

This was straightforward to implement using `Enum.map_reduce/3`. On each day,
I mapped over each element in the list and either decremented it or reset it to
6 if it was 0. If the value was 0, I also appended an 8 to the
accumulator which was a list of 8s generated on that day. After each
existing fish was updated, I concatenated the updated list with the newly
generated list. This implementation took approximately 8 seconds to solve
part 1.

## Part 2

I had a hunch that my approach to part 1 was not going to scale to part 2, but
I went ahead and ran it anyway. After sprinkling some `IO.inspect` calls, it
became clear that the iterations became prohibitively slow around day 80. I
needed a heuristic to reduce the space and time complexity.

My first thought was that the population would repeat in cycles. How long was
the period of the cycle? I wrote a function to iterate over a number of days
until the initial population repeated itself. It reported a period of 7 days
for the example dataset. I ran it on my puzzle input: 7 days again. I let out an
audible, "Ugh, duh." Of course it was 7 days, it even says so in the problem
description.

My next thought was that the population would double every 7 days. I attempted
to calculate the population after a number of complete 7-day-cycles by first
finding the number of times 7 divided cleanly into the total number of days.
I then calculcated 2 to the power of this number and multiplied it by the size
of the initial population. Then I attempted start running my implementation from
part 1 from this point. That didn't work either. After inspecting counts at
individual days some more it became clear that my observation that the
population doubled every 7-day-cycle did not hold behond day 14.

Eventually, I gave up and checked Reddit. The optimal solution was to first
count the number of fish of each age in the initial population. For each day,
you could then pop the head of the list: that is the number of fish of age
zero. You then append that count to the end of the list (new fish with age 8)
and also add it to the number of fish at age 6.

In hindsight, I fell into a couple traps when reading the problem description.
The first trap I fell into was that I got focused on the population sequence in
the example and did not re-read the entire problem. If I had, I would have seen
that it mentions that the population repeats every 7 days. The second trap I
fell into was getting stuck on the wording, "adds a new 8 to the end of the
list". The order of the fish in the list doesn't actually matter. All that
matters is the number of fish of each age each day.

## I Learned

- Re-read the entire problem description
- Be mindful of ways in which the description is guiding your thinking towards certain models

- `Enum.frequencies/1`
- `List.update_at/3`
- `IO.inspect/3`, `Inspect.Opts`
- `limit: :infinity` for inspecting large lists
- `width: :infinity` for inspecting large lists
- Sorting tuples (1st element)
