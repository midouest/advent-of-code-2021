# Day 10

## Part 1

Today's problem was the classic "balance parenthesis" problem with some small twists.

My approach was to use a recursive function that received the list of characters to be processed and a list of characters that were _expected_ to be processed. The function examined each input character and proceeded based on the following logic:

- If the input character is an "opening" bracket, then push its matching closing bracket onto the expected stack and proceed.
- If the input character is a "closing" bracket and it matches the closing bracket on the top of the expected stack, then pop top of the expected stack and proceed.
- If the input character is a closing bracket and it doesn't match the next expected bracket, then the line is corrupted. Return the score of the illegal character.
- If the input is empty but there are still expected closing characters, then the line is incomplete and we return `nil`.

I figured that the fourth clause would need to be refactored in some way for part 2.

The total score was calculated by mapping this function over the input, filtering `nil` results and then summing all the intermediate scores.

## Part 2

I realized that I already had all the information I needed to calculate the score for part 2. All I needed to do was refactor the return value of the bracket closing function to distinguish between corrupted and incomplete scores. I wrapped the return value in a tuple where the first element is either `:corrupted` or `:incomplete` and the second element is the score.

When finding the middle score, I figured that I could use `Enum.split` to split the sorted list of scores into two sections and then take the first element from the second list. In hindsight, I could have just called `Enum.at` with the index I would have passed to `Enum.split`... 🤦‍♀️
