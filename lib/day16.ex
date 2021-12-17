defmodule Advent.Day16 do
  alias Advent.Day16.Decoder

  def load_puzzle(), do: Advent.read("data/day16.txt")

  def part1() do
    load_puzzle()
    |> version_sum()
  end

  def part2() do
    load_puzzle()
    |> value()
  end

  def version_sum([line]) do
    line
    |> Decoder.parse()
    |> Decoder.decode(1)
    |> Decoder.version_sum()
  end

  def value([line]) do
    line
    |> Decoder.parse()
    |> Decoder.decode(1)
    |> Decoder.packet()
    |> evaluate()
  end

  defp evaluate(%{type_id: 0, packets: packets}), do: reduce(packets, &Enum.sum/1)
  defp evaluate(%{type_id: 1, packets: packets}), do: reduce(packets, &Enum.product/1)
  defp evaluate(%{type_id: 2, packets: packets}), do: reduce(packets, &Enum.min/1)
  defp evaluate(%{type_id: 3, packets: packets}), do: reduce(packets, &Enum.max/1)
  defp evaluate(%{type_id: 4, value: value}), do: value
  defp evaluate(%{type_id: 5, packets: packets}), do: compare(packets, &>/2)
  defp evaluate(%{type_id: 6, packets: packets}), do: compare(packets, &</2)
  defp evaluate(%{type_id: 7, packets: packets}), do: compare(packets, &==/2)

  defp reduce(packets, fun), do: Enum.map(packets, &evaluate/1) |> fun.()

  defp compare([left, right], fun) do
    if fun.(evaluate(left), evaluate(right)), do: 1, else: 0
  end
end

defmodule Advent.Day16.Decoder do
  defstruct input: [], packet: nil, packets: []

  alias __MODULE__, as: Decoder

  def parse(line) do
    line
    |> String.graphemes()
    |> Enum.flat_map(fn s ->
      String.to_integer(s, 16)
      |> Integer.digits(2)
      |> pad_leading()
    end)
    |> new()
  end

  def new(input), do: %Decoder{input: input}

  def packets(%Decoder{packets: packets}), do: packets
  def packet(%Decoder{packets: [packet]}), do: packet

  def version_sum(%Decoder{packets: packets}) do
    packets
    |> Enum.map(&sum_versions/1)
    |> Enum.sum()
  end

  def decode(%Decoder{} = decoder, 0), do: decoder

  def decode(%Decoder{} = decoder, n) do
    decoder
    |> take_header()
    |> take_payload()
    |> decode(n - 1)
  end

  def decode_all(%Decoder{input: []} = decoder), do: decoder

  def decode_all(%Decoder{} = decoder) do
    decoder
    |> decode(1)
    |> decode_all()
  end

  defp take_header(%Decoder{} = decoder) do
    decoder
    |> take_version()
    |> take_type()
  end

  defp take_version(%Decoder{input: input} = decoder) do
    {bits, input} = Enum.split(input, 3)
    version = Integer.undigits(bits, 2)
    %Decoder{decoder | input: input, packet: %{version: version}}
  end

  defp take_type(%Decoder{input: input, packet: packet} = decoder) do
    {bits, input} = Enum.split(input, 3)
    type_id = Integer.undigits(bits, 2)
    packet = Map.put(packet, :type_id, type_id)
    %Decoder{decoder | input: input, packet: packet}
  end

  defp take_payload(%Decoder{packet: %{type_id: type_id}} = decoder) do
    if type_id == 4, do: take_literal(decoder), else: take_operator(decoder)
  end

  defp take_literal(%Decoder{input: input, packet: packet, packets: packets} = decoder) do
    {value, input} = split_literal(input)
    packet = Map.put(packet, :value, value)
    packets = packets ++ [packet]
    %Decoder{decoder | input: input, packet: nil, packets: packets}
  end

  defp take_operator(
         %Decoder{input: [length_type_id | input], packet: packet, packets: packets} = decoder
       ) do
    {bits, input} =
      case length_type_id do
        0 -> Enum.split(input, 15)
        1 -> Enum.split(input, 11)
      end

    count = Integer.undigits(bits, 2)
    {subpackets, input} = split_subpackets(length_type_id, input, count)

    packet =
      packet
      |> Map.put(:length_type_id, length_type_id)
      |> Map.put(:length, count)
      |> Map.put(:packets, subpackets)

    packets = packets ++ [packet]
    %Decoder{decoder | input: input, packet: nil, packets: packets}
  end

  defp split_literal(input), do: split_literal(input, [])

  defp split_literal([0 | input], acc) do
    {bits, input} = Enum.split(input, 4)
    literal = Integer.undigits(acc ++ bits, 2)
    {literal, input}
  end

  defp split_literal([1 | input], acc) do
    {bits, input} = Enum.split(input, 4)
    split_literal(input, acc ++ bits)
  end

  defp split_subpackets(0, input, bit_count) do
    {input, rest} = Enum.split(input, bit_count)

    packets =
      input
      |> new()
      |> decode_all()
      |> packets()

    {packets, rest}
  end

  defp split_subpackets(1, input, packet_count) do
    %Decoder{input: input, packets: packets} =
      input
      |> new()
      |> decode(packet_count)

    {packets, input}
  end

  defp pad_leading(bits) when length(bits) == 4, do: bits
  defp pad_leading(bits), do: List.duplicate(0, 4 - length(bits)) ++ bits

  defp sum_versions(%{type_id: 4, version: version}), do: version

  defp sum_versions(%{version: version, packets: packets}) do
    version +
      (packets
       |> Enum.map(&sum_versions/1)
       |> Enum.sum())
  end
end
