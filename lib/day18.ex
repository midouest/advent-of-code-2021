defmodule Advent.Day18 do
  alias Advent.Day18.Num

  def load_puzzle(), do: Advent.read("data/day18.txt")

  def part1() do
    load_puzzle()
    |> answer1()
  end

  def part2() do
    load_puzzle()
    |> answer2()
  end

  def answer1(lines) do
    lines
    |> Enum.map(&Num.parse/1)
    |> Num.sum()
    |> Num.magnitude()
  end

  def answer2(lines) do
    for x <- lines, y <- lines, x != y, reduce: 0 do
      max_sum -> max(max_sum, answer1([x, y]))
    end
  end
end

defmodule Advent.Day18.Num do
  def parse(line), do: line |> Code.eval_string() |> elem(0)

  def magnitude(el) when is_integer(el), do: el
  def magnitude([left, right]), do: 3 * magnitude(left) + 2 * magnitude(right)

  def sum(pairs), do: Enum.reduce(pairs, &add(&2, &1))

  def add(left, right), do: reduce([left, right])

  def reduce(pair) do
    case explode(pair) do
      {true, pair} ->
        reduce(pair)

      _ ->
        case split(pair) do
          {true, pair} ->
            reduce(pair)

          _ ->
            pair
        end
    end
  end

  def explode(pair) do
    {exploded, tree, _, _} = explode(pair, 0)
    {exploded, tree}
  end

  def explode(el, _) when is_integer(el), do: {false, el, nil, nil}

  def explode([left, right] = pair, depth)
      when is_integer(left) and is_integer(right) do
    if depth >= 4 do
      {true, 0, left, right}
    else
      {false, pair, nil, nil}
    end
  end

  def explode([left, right] = pair, depth) do
    case explode(left, depth + 1) do
      {true, tree, lval, rval} ->
        {true, [tree, distribute(right, 0, rval)], lval, nil}

      _ ->
        case explode(right, depth + 1) do
          {true, tree, lval, rval} ->
            {true, [distribute(left, 1, lval), tree], nil, rval}

          _ ->
            {false, pair, nil, nil}
        end
    end
  end

  def distribute(el, _, nil), do: el
  def distribute(el, _, val) when is_integer(el), do: el + val

  def distribute(pair, index, val) do
    List.update_at(pair, index, &distribute(&1, index, val))
  end

  def split([left, right] = pair) do
    case split(left) do
      {true, tree} ->
        {true, [tree, right]}

      _ ->
        case split(right) do
          {true, tree} ->
            {true, [left, tree]}

          _ ->
            {false, pair}
        end
    end
  end

  def split(val) when is_integer(val) and val >= 10 do
    left = floor(val / 2)
    right = ceil(val / 2)
    {true, [left, right]}
  end

  def split(val), do: {false, val}
end
