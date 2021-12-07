defmodule Day07Test do
  use ExUnit.Case

  import Advent.Day07

  @example ["16,1,2,0,4,2,7,1,2,14"]

  test "part 1 example" do
    assert solve_constant(@example) == 37
  end

  test "part 2 example" do
    assert solve_increasing(@example) == 168
  end
end
