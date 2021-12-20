defmodule Advent.Day20 do
  alias Advent.Day20.Image

  def load_puzzle(), do: Advent.read("data/day20.txt")

  def part1() do
    load_puzzle()
    |> count_lit()
  end

  def part2() do
    load_puzzle()
    |> count_lit(50)
  end

  def count_lit(lines, count \\ 2) do
    lines
    |> Image.parse()
    |> Image.enhance(count)
    |> Image.count_lit()
  end
end

defmodule Advent.Day20.Image do
  defstruct algo: %{}, rows: [], w: 0, h: 0

  alias __MODULE__, as: I

  import Bitwise

  def parse([first | ["" | lines]]) do
    %I{}
    |> put_algo(first)
    |> put_rows(lines)
    |> pad(0b0, 1)
  end

  defp put_algo(%I{} = i, line) do
    algo =
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn
        {".", n}, acc -> Map.put(acc, n, 0b0)
        {"#", n}, acc -> Map.put(acc, n, 0b1)
      end)

    %I{i | algo: algo}
  end

  defp put_rows(%I{} = i, lines) do
    height = length(lines)
    width = String.length(hd(lines))
    rows = Enum.map(lines, &parse_row/1)

    %I{i | rows: rows, w: width, h: height}
  end

  defp parse_row(line) do
    line
    |> String.graphemes()
    |> Enum.map(fn
      "." -> 0b0
      "#" -> 0b1
    end)
    |> Integer.undigits(2)
  end

  def pad(%I{rows: rows, w: w, h: h} = i, bit, count) do
    {rows, pad_row} =
      case bit do
        0b0 ->
          {Enum.map(rows, &(&1 <<< count)), 0b0}

        0b1 ->
          pad = (0b1 <<< count) - 1
          rows = Enum.map(rows, &(pad <<< (w + count) ||| &1 <<< count ||| pad))
          pad_row = (0b1 <<< (w + 2 * count)) - 1
          {rows, pad_row}
      end

    pad_rows = List.duplicate(pad_row, count)
    rows = pad_rows ++ rows ++ pad_rows
    %I{i | rows: rows, w: w + 2 * count, h: h + 2 * count}
  end

  def expand(%I{rows: [first | _]} = i, count), do: pad(i, first &&& 0b1, count)

  def enhance(%I{} = i, 0), do: i

  def enhance(%I{algo: algo, w: w0, h: h0} = i0, count) do
    %I{w: w1, h: h1} = i1 = expand(i0, 2)

    rows =
      Enum.map(1..(h1 - 2), fn y ->
        Enum.map(1..(w1 - 2), fn x ->
          n = mask(i1, {x, y})
          Map.fetch!(algo, n)
        end)
        |> Integer.undigits(2)
      end)

    i2 = %I{algo: algo, rows: rows, w: w0 + 2, h: h0 + 2}
    enhance(i2, count - 1)
  end

  def mask(%I{rows: rows, w: w}, {x, y}) do
    rows
    |> Enum.slice(y - 1, 3)
    |> Enum.map(fn n ->
      offset = w - x - 2
      (n &&& 0b111 <<< offset) >>> offset
    end)
    |> Integer.undigits(8)
  end

  def count_lit(%{rows: rows}) do
    rows
    |> Enum.flat_map(&Integer.digits(&1, 2))
    |> Enum.sum()
  end

  def print(%I{rows: rows, w: w}, device \\ :stdio) do
    Enum.each(rows, fn row ->
      row
      |> Integer.digits(2)
      |> pad_digits(w)
      |> Enum.each(fn
        0b1 -> IO.write(device, "#")
        0b0 -> IO.write(device, ".")
      end)

      IO.write(device, "\n")
    end)
  end

  defp pad_digits(digits, w), do: List.duplicate(0, w - length(digits)) ++ digits
end
