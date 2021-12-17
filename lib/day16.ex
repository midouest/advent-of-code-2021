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
    |> Decoder.packet()
    |> sum_versions()
  end

  def value([line]) do
    line
    |> Decoder.parse()
    |> Decoder.decode(1)
    |> Decoder.packet()
    |> evaluate()
  end

  defp sum_versions(%{type_id: 4, version: version}), do: version

  defp sum_versions(%{version: version, packets: packets}) do
    version +
      (packets
       |> Enum.map(&sum_versions/1)
       |> Enum.sum())
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
  defstruct input: [], partial: %{}, packets: []

  alias __MODULE__, as: D

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

  def new(input), do: %D{input: input}

  def packets(%D{packets: packets}), do: packets
  def packet(%D{packets: [packet]}), do: packet

  def decode(%D{} = decoder, 0), do: decoder

  def decode(%D{} = decoder, n) do
    decoder
    |> version()
    |> type()
    |> payload()
    |> decode(n - 1)
  end

  def decode_all(%D{input: []} = decoder), do: decoder

  def decode_all(%D{} = decoder) do
    decoder
    |> decode(1)
    |> decode_all()
  end

  defp version(%D{input: input, partial: partial} = decoder) do
    {bits, input} = Enum.split(input, 3)
    version = Integer.undigits(bits, 2)
    partial = Map.put(partial, :version, version)
    %D{decoder | input: input, partial: partial}
  end

  defp type(%D{input: input, partial: partial} = decoder) do
    {bits, input} = Enum.split(input, 3)
    type_id = Integer.undigits(bits, 2)
    partial = Map.put(partial, :type_id, type_id)
    %D{decoder | input: input, partial: partial}
  end

  defp payload(%D{partial: %{type_id: type_id}} = decoder) do
    if type_id == 4, do: literal(decoder), else: operator(decoder)
  end

  defp literal(%D{input: input, partial: partial, packets: packets}) do
    {value, input} = decode_literal(input)
    partial = Map.put(partial, :value, value)
    packets = packets ++ [partial]
    %D{input: input, partial: %{}, packets: packets}
  end

  defp operator(%D{input: [len_type_id | input], partial: partial, packets: packets}) do
    {bits, input} =
      case len_type_id do
        0 -> Enum.split(input, 15)
        1 -> Enum.split(input, 11)
      end

    len = Integer.undigits(bits, 2)
    {subpackets, input} = decode_subpackets(len_type_id, input, len)
    partial = Map.put(partial, :packets, subpackets)
    packets = packets ++ [partial]
    %D{input: input, partial: %{}, packets: packets}
  end

  defp decode_literal(input), do: decode_literal(input, [])

  defp decode_literal([0 | input], acc) do
    {bits, input} = Enum.split(input, 4)
    literal = Integer.undigits(acc ++ bits, 2)
    {literal, input}
  end

  defp decode_literal([1 | input], acc) do
    {bits, input} = Enum.split(input, 4)
    decode_literal(input, acc ++ bits)
  end

  defp decode_subpackets(0, input, bit_count) do
    {input, rest} = Enum.split(input, bit_count)

    packets =
      input
      |> new()
      |> decode_all()
      |> packets()

    {packets, rest}
  end

  defp decode_subpackets(1, input, packet_count) do
    %D{input: input, packets: packets} =
      input
      |> new()
      |> decode(packet_count)

    {packets, input}
  end

  defp pad_leading(bits) when length(bits) == 4, do: bits
  defp pad_leading(bits), do: List.duplicate(0, 4 - length(bits)) ++ bits
end
