defmodule Advent.Day23 do
  alias Advent.Day23.Burrow

  def load_puzzle(), do: Advent.read("data/day23.txt", &String.trim_trailing/1)

  def part1() do
    load_puzzle()
    |> organize()
  end

  def part2() do
    load_puzzle()
    |> organize(true)
  end

  @folded [
    "  #D#C#B#A#",
    "  #D#B#A#C#"
  ]

  def organize(lines, unfold? \\ false) do
    lines =
      if unfold?,
        do: List.insert_at(lines, 3, @folded) |> List.flatten(),
        else: lines

    init = Burrow.parse(lines)
    frontier = [init]
    visited = %{init => 0}
    prev = %{}

    dfs(frontier, visited, prev, :infinity)
  end

  def dfs([], _, _, best) do
    best
  end

  def dfs([state | frontier], visited, prev, best) do
    prev_cost = Map.get(visited, state)

    cond do
      Burrow.final?(state) ->
        best = min(prev_cost, best)
        dfs(frontier, visited, prev, best)

      prev_cost >= best ->
        dfs(frontier, visited, prev, best)

      true ->
        {frontier, visited, prev} =
          Burrow.neighbors(state)
          |> Enum.reduce({frontier, visited, prev}, fn {next_state, cost},
                                                       {frontier, visited, prev} ->
            next_cost = prev_cost + cost

            if next_cost < Map.get(visited, next_state) do
              frontier = [next_state | frontier]
              visited = Map.put(visited, next_state, next_cost)
              prev = Map.put(prev, next_state, state)
              {frontier, visited, prev}
            else
              {frontier, visited, prev}
            end
          end)

        dfs(frontier, visited, prev, best)
    end
  end
end

defmodule Advent.Day23.Amphipod do
  def amphipod?("A"), do: true
  def amphipod?("B"), do: true
  def amphipod?("C"), do: true
  def amphipod?("D"), do: true
  def amphipod?(_), do: false

  def energy(3), do: 1
  def energy(5), do: 10
  def energy(7), do: 100
  def energy(9), do: 1000

  @doc """
  Encode amphipods as their desired final x position so that we can compare the
  desired x position to the current x position to determine if an amphipod is
  in its final room.
  """
  def room_x("A"), do: 3
  def room_x("B"), do: 5
  def room_x("C"), do: 7
  def room_x("D"), do: 9

  def to_string(3), do: "A"
  def to_string(5), do: "B"
  def to_string(7), do: "C"
  def to_string(9), do: "D"
end

defmodule Advent.Day23.Burrow do
  defstruct [:map, :y_max]

  alias __MODULE__, as: Burrow
  alias Advent.Day23.Amphipod

  def parse(lines) do
    map =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {c, _} -> Amphipod.amphipod?(c) end)
        |> Enum.map(fn {c, x} -> {{x, y}, {Amphipod.room_x(c), 0}} end)
      end)
      |> Map.new()

    y_max =
      map
      |> Map.keys()
      |> Enum.max_by(&elem(&1, 1))
      |> elem(1)

    %Burrow{map: map, y_max: y_max}
  end

  def neighbors(%Burrow{map: map} = b) do
    map
    |> Enum.filter(fn {coord, _} -> must_move?(b, coord) end)
    |> Enum.flat_map(fn {coord, {amp, _}} ->
      e = Amphipod.energy(amp)

      moves(b, coord)
      |> Enum.map(fn dest ->
        burrow = move(b, coord, dest)
        energy = cost(e, coord, dest)
        {burrow, energy}
      end)
    end)
  end

  def final?(%Burrow{map: map}) do
    Enum.all?(map, fn {{x, y}, {a, _}} -> y > 1 and x == a end)
  end

  def move(%Burrow{map: map} = b, initial, dest) do
    {{amp, n}, map} = Map.pop!(map, initial)
    map = Map.put(map, dest, {amp, n + 1})

    %Burrow{b | map: map}
  end

  def moves(%Burrow{map: map, y_max: y_max} = b, initial) do
    frontier =
      initial
      |> adjacent(y_max)
      |> Enum.reject(&Map.has_key?(map, &1))

    valid_moves(b, initial, frontier, MapSet.new(), [])
  end

  def cost(e, a, b), do: e * distance(a, b)

  def distance({x1, y1}, {x2, y2}) when y1 > 1 and y2 > 1 do
    abs(x2 - x1) + y2 + y1 - 2
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  def valid_moves(_, _, [], _, valid), do: valid

  def valid_moves(%Burrow{map: map, y_max: y_max} = b, initial, frontier, visited, valid) do
    visited =
      frontier
      |> MapSet.new()
      |> MapSet.union(visited)

    {next_frontier, valid} =
      Enum.reduce(frontier, {[], valid}, fn coord, {next_frontier, valid} ->
        valid =
          if valid_move?(b, initial, coord) do
            [coord | valid]
          else
            valid
          end

        unexplored =
          coord
          |> adjacent(y_max)
          |> Enum.reject(&(MapSet.member?(visited, &1) or Map.has_key?(map, &1)))

        {next_frontier ++ unexplored, valid}
      end)

    valid_moves(b, initial, next_frontier, visited, valid)
  end

  def valid_move?(%Burrow{map: map} = b, initial, coord) do
    {amp, n} = Map.fetch!(map, initial)

    cond do
      n >= 2 ->
        false

      outside_room?(coord) ->
        # Amphipods will never stop on the space immediately outside any room.
        # They can move into that space so long as they immediately continue
        # moving. (Specifically, this refers to the four open spaces in the
        # hallway that are directly above an amphipod starting position.)
        false

      Map.has_key?(map, coord) ->
        # Amphipods can move up, down, left, or right so long as they are moving
        # into an unoccupied open space.
        false

      in_room?(initial) and in_room?(coord) ->
        false

      in_hallway?(initial) ->
        cond do
          in_hallway?(coord) ->
            # Once an amphipod stops moving in the hallway, it will stay in that
            # spot until it can move into a room. (That is, once any amphipod starts
            # moving, any other amphipods currently in the hallway are locked in
            # place and will not move again until they can move fully into a room.)
            false

          in_final_room?(coord, amp) and
            not stranger_in_room?(b, amp) and
              best_room_coord?(b, coord) ->
            # Amphipods will never move from the hallway into a room unless that
            # room is their destination room and that room contains no amphipods
            # which do not also have that room as their own destination. If an
            # amphipod's starting room is not its destination room, it can stay in
            # that room until it leaves the room. (For example, an Amber amphipod
            # will not move from the hallway into the right three rooms, and will
            # only move into the leftmost room if that room is empty or if it only
            # contains other Amber amphipods.)
            true

          true ->
            false
        end

      true ->
        true
    end
  end

  def adjacent({1, 1}, _), do: [{2, 1}]
  def adjacent({11, 1}, _), do: [{10, 1}]

  def adjacent({x, 1}, _) when x == 3 or x == 5 or x == 7 or x == 9,
    do: [{x - 1, 1}, {x, 2}, {x + 1, 1}]

  def adjacent({x, 1}, _), do: [{x - 1, 1}, {x + 1, 1}]
  def adjacent({x, y}, y), do: [{x, y - 1}]
  def adjacent({x, y}, _), do: [{x, y - 1}, {x, y + 1}]

  def in_hallway?({_, y}), do: y == 1

  def in_room?({_, y}), do: y > 1

  def in_final_room?({x, _} = coord, amp), do: in_room?(coord) and x == amp

  def outside_room?({x, _} = coord) do
    in_hallway?(coord) and
      case x do
        3 -> true
        5 -> true
        7 -> true
        9 -> true
        _ -> false
      end
  end

  def best_room_coord?(%Burrow{map: map, y_max: y_max}, {x, y}) do
    best_y = Enum.find(y_max..2//-1, fn y -> Map.get(map, {x, y}) == nil end)
    y == best_y
  end

  def stranger_in_room?(%Burrow{map: map, y_max: y_max}, amp) do
    # Default to amp to allow entering empty rooms
    2..y_max
    |> Enum.any?(fn y ->
      {other, _} = Map.get(map, {amp, y}, {amp, nil})
      other != amp
    end)
  end

  @doc """
  An amphipod must move if it's not in its final room. If the amphipod is in
  its final room, it must move if it's blocking the other empty spot in the
  final room.
  """
  def must_move?(%Burrow{map: map, y_max: y_max}, {x, y} = coord) when y > 1 do
    {amp, _} = Map.get(map, coord)

    amp != x or
      y..y_max
      |> Enum.any?(fn y ->
        {other, _} = Map.get(map, {x, y}, {nil, nil})
        other != amp
      end)
  end

  def must_move?(_, _), do: true

  def print(%Burrow{map: map, y_max: y_max}) do
    IO.puts("#############")

    IO.write("#")
    Enum.each(1..11, fn x -> print_coord(map, {x, 1}) end)
    IO.puts("#")

    IO.write("###")

    Enum.each(3..9//2, fn x ->
      print_coord(map, {x, 2})
      IO.write("#")
    end)

    IO.puts("##")

    Enum.each(3..y_max, fn y ->
      IO.write("  #")

      Enum.each(3..9//2, fn x ->
        print_coord(map, {x, y})
        IO.write("#")
      end)

      IO.puts("")
    end)

    IO.puts("  #########")
  end

  def print_coord(map, coord) do
    case Map.get(map, coord) do
      nil -> "."
      {a, _} -> Amphipod.to_string(a)
    end
    |> IO.write()
  end
end
