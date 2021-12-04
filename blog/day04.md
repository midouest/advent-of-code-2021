# Day 4

## Part 1

My first thought was to abstract the board state and logic into a `Board` module. I figured that a board could be a one or two-dimensional array of integers. So far I have only dealt with lists (`[]`) which I know do not support `O(1)` random access. Every index into a list using `Enum.at/2` has to linearly scan the list up until the requested index.

After a bit of Googling, I learned that there are two options for avoiding linear array indexing in Elixir: `Map` and `:array`. The `Map` approach implements arrays using a map (`%{}`) structure with indexes as keys. The `:array` approach uses the Erlang `:array` module which implements arrays as tuples. It's worth noting that this may be premature optimization. The [benchmarks](https://github.com/Qqwy/elixir-arrays#benchmarks) section of the Elixir Arrays package indicates that lists are superior for random access below about 128 entries.

I figured the `Board` module would also need a function to mark a cell as having been drawn already. This meant I would need to store the state of each cell somewhere. I decided to store it as a tuple along with the value of the cell. I was also concerned about having to do linear searches across all values in the board when checking for the win state. I decided I would store a reverse lookup that mapped a number stored in the board to the coordinates that it was stored at. This allowed me to mark a cell as drawn with two look-ups: one to retrieve the coordinates of the number, and another to update the state of the cell.

I decided that the best place to check if the board was in a winning state was immediately after marking a cell as drawn. I also realized a simple heuristic to speed up checking the board state: the winning row or column must include the cell that was just checked. Therefore, we only have to check a single row and column after each update to determine if a board has won or not.

I calculated the solution to part 1 using `Enum.reduce_while/3` over the sequence of drawn numbers. For each number, I marked the number in each board and checked for a winning board. If any board won, then I stopped iteration by returning a tuple of `:halt` and the winning board. Otherwise, I returned a tuple of `:cont` and the new board states.

## Part 2

Part 2 was once again generalization of my solution to part 1. In part 1, I played until the first board was in a winning state and then returned the score. In part 2, I would need to play each board to a winning state and return the score of the last board. I figured I could solve this by parameterizing `Enum.reduce_while` to stop as a function of the total number of boards and the number of winning boards. The part 1 solution would stop as soon as there was a single winning board. The part 2 solution would stop as soon as every board was a winning board.

The first issue I ran into while refactoring my solution was distinguishing boards that had won on a previous draw vs boards that had _just_ won. I was hoping to concatenate each board to a list of winning boards as new winners came in. My existing implementation would have returned the entire set of winning boards on each iteration. I eventually decided to store the win state of the board in the data model and early out when marking the board if it was already in a winning state. This had the advantage of reducing the computation time for future iterations.

I ran into another issue after building the list of winners. I needed the number that a given board won on in order to calculate its score. In order to calculate the score for the first or last board, I would also need to know the number drawn during that iteration. In hindsight, I could have sovled this by pairing a winning board with its draw in a tuple. In the moment, I decided that it would be easier to calculate the score of each winning board and take the first or last score from this list.

## Reddit

In hindsight, it seems like a lot of the decisions I made around linear list lookups were premature optimization. I found a lot of solutions in Elixir that simply iterated over the entire set of drawn numbers for each cell in each board every time a new number was drawn. I'm not sure if this was faster or slower than my implementation, but it was certainly fewer lines of code.

## I Learned

- `O(1)` arrays in Elixir
- `defstruct` and `__MODULE__`
- `String.splitter/3` and `trim: true` argument
- `Stream.with_index/1`
- `Map.put/3`
- Syntax sugar for getting and updating an existing entry in a `Map`
