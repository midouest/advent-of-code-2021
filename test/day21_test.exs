defmodule Day21Test do
  use ExUnit.Case

  import Advent.Day21

  @example [
    "Player 1 starting position: 4",
    "Player 2 starting position: 8"
  ]

  test "part 1 example" do
    assert play_practice_game(@example) == 739_785
  end

  test "part 2 example" do
    assert play_dirac_game(@example) == 444_356_092_776_315
  end
end
