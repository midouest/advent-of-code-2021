defmodule Day16Test do
  use ExUnit.Case

  import Advent.Day16
  alias Advent.Day16.Decoder

  @literal "D2FE28"
  @operator1 "38006F45291200"
  @operator2 "EE00D40C823060"

  test "literal" do
    packet =
      @literal
      |> Decoder.parse()
      |> Decoder.decode(1)
      |> Decoder.packet()

    assert packet == %{version: 6, type_id: 4, value: 2021}
  end

  test "operator 1" do
    packet =
      @operator1
      |> Decoder.parse()
      |> Decoder.decode(1)
      |> Decoder.packet()

    assert packet ==
             %{
               version: 1,
               type_id: 6,
               packets: [
                 %{version: 6, type_id: 4, value: 10},
                 %{version: 2, type_id: 4, value: 20}
               ]
             }
  end

  test "operator 2" do
    packet =
      @operator2
      |> Decoder.parse()
      |> Decoder.decode(1)
      |> Decoder.packet()

    assert packet ==
             %{
               version: 7,
               type_id: 3,
               packets: [
                 %{version: 2, type_id: 4, value: 1},
                 %{version: 4, type_id: 4, value: 2},
                 %{version: 1, type_id: 4, value: 3}
               ]
             }
  end

  @part1_example1 ["8A004A801A8002F478"]
  @part1_example2 ["620080001611562C8802118E34"]
  @part1_example3 ["C0015000016115A2E0802F182340"]
  @part1_example4 ["A0016C880162017C3686B18A3D4780"]

  test "part 1 example 1" do
    assert version_sum(@part1_example1) == 16
  end

  test "part 1 example 2" do
    assert version_sum(@part1_example2) == 12
  end

  test "part 1 example 3" do
    assert version_sum(@part1_example3) == 23
  end

  test "part 1 example 4" do
    assert version_sum(@part1_example4) == 31
  end

  @part2_example1 ["C200B40A82"]
  @part2_example2 ["04005AC33890"]
  @part2_example3 ["880086C3E88112"]
  @part2_example4 ["CE00C43D881120"]
  @part2_example5 ["D8005AC2A8F0"]
  @part2_example6 ["F600BC2D8F"]
  @part2_example7 ["9C005AC2F8F0"]
  @part2_example8 ["9C0141080250320F1802104A08"]

  test "part 2 example 1" do
    assert value(@part2_example1) == 3
  end

  test "part 2 example 2" do
    assert value(@part2_example2) == 54
  end

  test "part 2 example 3" do
    assert value(@part2_example3) == 7
  end

  test "part 2 example 4" do
    assert value(@part2_example4) == 9
  end

  test "part 2 example 5" do
    assert value(@part2_example5) == 1
  end

  test "part 2 example 6" do
    assert value(@part2_example6) == 0
  end

  test "part 2 example 7" do
    assert value(@part2_example7) == 0
  end

  test "part 2 example 8" do
    assert value(@part2_example8) == 1
  end
end
