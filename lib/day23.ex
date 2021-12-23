defmodule Advent.Day23 do
  alias Advent.Day23.State
  alias Advent.Day23.Burrow
  alias Astar

  def load_puzzle(), do: Advent.read("data/day23.txt", &String.trim_trailing/1)

  def part1() do
    load_puzzle()
    |> organize()
  end

  def part2() do
    load_puzzle()
  end

  def organize(lines) do
    nbs = &State.neighbors/1
    dist = fn _, b -> b.cost end
    h = fn a, _ -> 1.5 * State.estimated_cost(a) end
    env = {nbs, dist, h}

    start = State.parse(lines)
    goal = fn a -> State.final?(a) end

    Astar.astar(env, start, goal)
    |> Enum.map(fn state -> state.cost end)
    |> Enum.sum()
  end
end

defmodule Advent.Day23.State do
  defstruct map: nil, cost: 0

  alias __MODULE__, as: State
  alias Advent.Day23.Burrow
  alias Advent.Day23.Amphipod

  def parse(lines) do
    map = Burrow.parse(lines)
    %State{map: map}
  end

  def estimated_cost(%State{map: map}) do
    map
    |> Enum.filter(fn {coord, amp} -> Burrow.must_move?(map, amp, coord) end)
    |> Enum.map(fn {coord, amp} ->
      e = Amphipod.energy(amp)
      # Assume worst case
      Burrow.cost(e, coord, {amp, 3})
    end)
    |> Enum.sum()
  end

  def neighbors(%State{map: map}) do
    map
    |> Enum.filter(fn {coord, amp} -> Burrow.must_move?(map, amp, coord) end)
    |> Enum.flat_map(fn {coord, amp} ->
      e = Amphipod.energy(amp)

      Burrow.moves(map, coord, amp, e)
      |> Enum.map(fn {dest, cost} ->
        map =
          map
          |> Map.delete(coord)
          |> Map.put(dest, amp)

        %State{map: map, cost: cost}
      end)
    end)
  end

  def final?(%State{map: map}) do
    Enum.all?(map, fn {{x, y}, a} -> y > 1 and x == a end)
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
  alias Advent.Day23.Amphipod

  def parse(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {c, _} -> Amphipod.amphipod?(c) end)
      |> Enum.map(fn {c, x} -> {{x, y}, Amphipod.room_x(c)} end)
    end)
    |> Map.new()
  end

  def moves(map, initial, amp, e) do
    frontier =
      initial
      |> neighbors()
      |> Enum.reject(&Map.has_key?(map, &1))

    valid_moves(map, amp, initial, frontier, MapSet.new(), [])
    |> Enum.map(fn coord -> {coord, cost(e, initial, coord)} end)
  end

  def cost(e, a, b), do: e * distance(a, b)

  def distance({x1, y1}, {x2, y2}) when y1 > 1 and y2 > 1 do
    abs(x2 - x1) + y2 + y1 - 2
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  def valid_moves(_, _, _, [], _, valid), do: valid

  def valid_moves(map, amp, initial, frontier, visited, valid) do
    visited =
      frontier
      |> MapSet.new()
      |> MapSet.union(visited)

    {next_frontier, valid} =
      Enum.reduce(frontier, {[], valid}, fn coord, {next_frontier, valid} ->
        valid =
          if valid_move?(map, amp, initial, coord) do
            [coord | valid]
          else
            valid
          end

        unexplored =
          coord
          |> neighbors()
          |> Enum.reject(&(MapSet.member?(visited, &1) or Map.has_key?(map, &1)))

        {next_frontier ++ unexplored, valid}
      end)

    valid_moves(map, amp, initial, next_frontier, visited, valid)
  end

  def valid_move?(map, amp, initial, coord) do
    cond do
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

      in_hallway?(initial) ->
        cond do
          in_hallway?(coord) ->
            # Once an amphipod stops moving in the hallway, it will stay in that
            # spot until it can move into a room. (That is, once any amphipod starts
            # moving, any other amphipods currently in the hallway are locked in
            # place and will not move again until they can move fully into a room.)
            false

          in_final_room?(coord, amp) and not stranger_in_room?(map, amp) ->
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

  def neighbors({1, 1}), do: [{2, 1}]
  def neighbors({11, 1}), do: [{10, 1}]

  def neighbors({x, 1}) when x == 3 or x == 5 or x == 7 or x == 9,
    do: [{x - 1, 1}, {x, 2}, {x + 1, 1}]

  def neighbors({x, 1}), do: [{x - 1, 1}, {x + 1, 1}]
  def neighbors({x, 2}), do: [{x, 1}, {x, 3}]
  def neighbors({x, 3}), do: [{x, 2}]

  def in_hallway?({_, y}), do: y == 1

  def in_room?({_, y}), do: y == 2 or y == 3

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

  def stranger_in_room?(map, amp) do
    # Default to amp to allow entering empty rooms
    Map.get(map, {amp, 2}, amp) != amp or
      Map.get(map, {amp, 3}, amp) != amp
  end

  @doc """
  An amphipod must move if it's not in its final room. If the amphipod is in
  its final room, it must move if it's blocking the other empty spot in the
  final room.
  """
  def must_move?(map, amp, {x, 2}), do: amp != x or amp != Map.get(map, {x, 3})
  def must_move?(_, amp, {x, 3}), do: amp != x
  def must_move?(_, _, _), do: true

  def print(map) do
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

    IO.write("  #")

    Enum.each(3..9//2, fn x ->
      print_coord(map, {x, 3})
      IO.write("#")
    end)

    IO.puts("")
    IO.puts("  #########")
  end

  def print_coord(map, coord) do
    case Map.get(map, coord) do
      nil -> "."
      a -> Amphipod.to_string(a)
    end
    |> IO.write()
  end
end
