defmodule Day06Test do
  use ExUnit.Case

  @example ["3,4,3,1,2"]

  test "part 1 example 18 days" do
    assert Advent.Day06.simulate(@example, 18) == 26
  end

  test "part 1 example 80 days" do
    assert Advent.Day06.simulate(@example, 80) == 5934
  end

  test "part 2 example" do
    assert Advent.Day06.simulate(@example, 256) == 26_984_457_539
  end
end
