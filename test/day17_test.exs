defmodule Day17Test do
  use ExUnit.Case

  import Advent.Day17

  @example ["target area: x=20..30, y=-10..-5"]

  test "part 1 example" do
    assert highest_y_position(@example) == 45
  end

  test "part 2 example" do
    assert possible_velocities(@example) == 112
  end
end
