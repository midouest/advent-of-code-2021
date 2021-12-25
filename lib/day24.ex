defmodule Advent.Day24 do
  alias Advent.Day24.Solver

  def load_puzzle(), do: Advent.read("data/day24.txt")

  def part1() do
    exps =
      load_puzzle()
      |> Solver.parse()

    cs = Solver.explore_all(exps)
    n = Solver.find_largest(exps, cs)

    if Solver.valid?(exps, n), do: n, else: raise("Found invalid model number")
  end

  def part2() do
    exps =
      load_puzzle()
      |> Solver.parse()

    cs = Solver.explore_all(exps)
    n = Solver.find_smallest(exps, cs)

    if Solver.valid?(exps, n), do: n, else: raise("Found invalid model number")
  end
end

defmodule Advent.Day24.Solver do
  alias Advent.Day24.Program

  def parse(lines) do
    lines
    |> Enum.chunk_every(18)
    |> Enum.with_index()
    |> Enum.map(fn {lines, d} ->
      exp =
        lines
        |> Program.parse(d)
        |> Program.run()
        |> Map.get(:z)

      {d, exp}
    end)
    |> Map.new()
  end

  def valid?(exps, input) do
    input
    |> Integer.digits()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {d, i}, z ->
      eval(exps[i], %{{:d, i} => d, {:z, i - 1} => z})
    end) == 0
  end

  def explore_all(exps) do
    exp = exps[0]

    zs =
      for d <- 1..9, reduce: MapSet.new() do
        acc -> MapSet.put(acc, eval(exp, %{{:d, 0} => d}))
      end

    explore_all(exps, 1, {1, 0}, %{0 => zs})
  end

  def explore_all(exps, 13, {prev, time}, zs) do
    explore_back_all(exps, {prev, time}, zs)
  end

  def explore_all(exps, n, {prev, time}, zs) do
    ms_n = time / prev
    in_zs = zs[n - 1]
    input = MapSet.size(in_zs)
    est = input * ms_n

    IO.puts(~s"#{n} input #{input} (estimated #{est} ms)")

    {out_zs, ms} =
      Advent.measure(fn ->
        explore(exps, n, in_zs)
      end)

    output = MapSet.size(out_zs)
    IO.puts(~s"#{n} output #{output} (actual #{ms} ms)")

    l = Enum.min(out_zs)
    u = Enum.max(out_zs)
    IO.puts(~s"#{n} bounds #{l}..#{u}\n")

    zs = Map.put(zs, n, out_zs)
    explore_all(exps, n + 1, {input, ms}, zs)
  end

  def explore(exps, n, zs) do
    1..9
    |> Enum.map(fn d ->
      Task.async(fn ->
        exp = eval(exps[n], %{{:d, n} => d})

        for zn <- zs, reduce: MapSet.new() do
          acc ->
            z = eval(exp, %{{:z, n - 1} => zn})
            MapSet.put(acc, z)
        end
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.reduce(fn a, b ->
      MapSet.union(a, b)
    end)
  end

  def explore_back_all(exps, {prev, time}, zs) do
    explore_back_all(exps, 13, {prev, time}, zs, %{13 => MapSet.new([0])})
  end

  def explore_back_all(_, 0, _, _, cs) do
    cs
  end

  def explore_back_all(exps, n, {prev, time}, zs, cs) do
    ms_n = time / prev
    in_zs = zs[n - 1]
    input = MapSet.size(in_zs)
    est = input * ms_n

    IO.puts(~s"#{n} input #{input} (estimated #{est} ms)")

    {out_cs, ms} =
      Advent.measure(fn ->
        explore_back(exps, n, zs, cs)
      end)

    output = MapSet.size(out_cs)
    IO.puts(~s"#{n} output #{output} (actual #{ms} ms)")

    l = Enum.min(out_cs)
    u = Enum.max(out_cs)
    IO.puts(~s"#{n} bounds #{l}..#{u}\n")

    cs = Map.put(cs, n - 1, out_cs)
    explore_back_all(exps, n - 1, {input, ms}, zs, cs)
  end

  def explore_back(exps, n, zs, cs) do
    1..9
    |> Enum.map(fn d ->
      Task.async(fn ->
        exp = eval(exps[n], %{{:d, n} => d})

        for z <- zs[n - 1],
            MapSet.member?(cs[n], eval(exp, %{{:z, n - 1} => z})),
            reduce: MapSet.new() do
          acc -> MapSet.put(acc, z)
        end
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.reduce(fn a, b ->
      MapSet.union(a, b)
    end)
  end

  def find_largest(exps, cs), do: find_all(exps, 9..1, cs)
  def find_smallest(exps, cs), do: find_all(exps, 1..9, cs)

  def find_all(exps, ds, cs) do
    {d, zn} =
      ds
      |> Enum.map(fn d ->
        zn = eval(exps[0], %{{:d, 0} => d})
        {d, zn}
      end)
      |> Enum.find(fn {_, zn} ->
        MapSet.member?(cs[0], zn)
      end)

    found = [d]
    find_all(exps, 1, zn, ds, cs, found)
  end

  def find_all(_, 14, _, _, _, found) do
    found
    |> Enum.reverse()
    |> Integer.undigits()
  end

  def find_all(exps, n, z, ds, cs, found) do
    {d, zn} = find(exps, n, z, ds, cs)
    found = [d | found]
    find_all(exps, n + 1, zn, ds, cs, found)
  end

  def find(exps, n, z, ds, cs) do
    ds
    |> Enum.map(fn d ->
      zn = eval(exps[n], %{{:d, n} => d, {:z, n - 1} => z})
      {d, zn}
    end)
    |> Enum.find(fn {_, zn} ->
      MapSet.member?(cs[n], zn)
    end)
  end

  def dump(z, d), do: ~s"z#{d} = " <> dump(z)
  def dump(x) when is_integer(x), do: Integer.to_string(x)
  def dump({:inp, d}), do: ~s"d#{d}"
  def dump({:add, a, b}), do: ~s"(#{dump(a)} + #{dump(b)})"
  def dump({:mul, a, b}), do: ~s"(#{dump(a)} * #{dump(b)})"
  def dump({:div, a, b}), do: ~s"(#{dump(a)} / #{dump(b)})"
  def dump({:mod, a, b}), do: ~s"(#{dump(a)} % #{dump(b)})"
  def dump({:eql, a, b}), do: ~s"(#{dump(a)} == #{dump(b)})"
  def dump({var, d}), do: Atom.to_string(var) <> Integer.to_string(d)

  def eval(x, _) when is_integer(x), do: x
  def eval({:inp, d} = e, env), do: Map.get(env, {:d, d}, e)

  def eval({:add, a, b}, env) do
    resolve(a, b, env, fn
      a, b when is_integer(a) and is_integer(b) -> a + b
      a, b -> {:add, a, b}
    end)
  end

  def eval({:mul, a, b}, env) do
    resolve(a, b, env, fn
      a, b when is_integer(a) and is_integer(b) -> a * b
      a, b -> {:mul, a, b}
    end)
  end

  def eval({:div, a, b}, env) do
    resolve(a, b, env, fn
      _, 0 -> :error
      a, b when is_integer(a) and is_integer(b) -> div(a, b)
      a, b -> {:div, a, b}
    end)
  end

  def eval({:mod, a, b}, env) do
    resolve(a, b, env, fn
      a, b when is_integer(a) and is_integer(b) ->
        if a < 0 or b <= 0 do
          :error
        else
          Integer.mod(a, b)
        end

      a, b ->
        {:mod, a, b}
    end)
  end

  def eval({:eql, a, b}, env) do
    resolve(a, b, env, fn
      a, b when is_integer(a) and is_integer(b) -> if a == b, do: 1, else: 0
      a, b -> {:eql, a, b}
    end)
  end

  def eval({_, _} = var, env), do: Map.get(env, var, var)

  defp resolve(a, b, env, fun) do
    case {eval(a, env), eval(b, env)} do
      {:error, _} -> :error
      {_, :error} -> :error
      {a, b} -> fun.(a, b)
    end
  end
end

defmodule Advent.Day24.Program do
  def parse(lines, d \\ 0) do
    instructions = Enum.map(lines, &parse_instruction/1)

    {w, x, y, z} =
      if d == 0 do
        {0, 0, 0, 0}
      else
        d = d - 1
        {{:w, d}, {:x, d}, {:y, d}, {:z, d}}
      end

    %{instructions: instructions, d: d, w: w, x: x, y: y, z: z}
  end

  defp parse_instruction(line) do
    case String.split(line, " ") do
      ["inp", a] ->
        {:inp, String.to_atom(a)}

      [op, a, b] ->
        b =
          case Integer.parse(b) do
            :error -> String.to_atom(b)
            {b, _} -> b
          end

        {String.to_atom(op), String.to_atom(a), b}
    end
  end

  def run(%{instructions: []} = p), do: p
  def run(p), do: execute(p) |> run()

  def execute(%{instructions: [{:inp, a} | rest], d: d} = p) do
    %{p | :d => d + 1, a => {:inp, d}, instructions: rest}
  end

  def execute(%{instructions: [{:add, a, b} | rest]} = p) do
    bin_op(p, :add, a, b, rest)
  end

  def execute(%{instructions: [{:mul, a, b} | rest]} = p) do
    bin_op(p, :mul, a, b, rest)
  end

  def execute(%{instructions: [{:div, a, b} | rest]} = p) do
    bin_op(p, :div, a, b, rest)
  end

  def execute(%{instructions: [{:mod, a, b} | rest]} = p) do
    bin_op(p, :mod, a, b, rest)
  end

  def execute(%{instructions: [{:eql, a, b} | rest]} = p) do
    bin_op(p, :eql, a, b, rest)
  end

  def tree(:add, 0, b), do: b
  def tree(:add, a, 0), do: a
  def tree(:add, a, b) when is_integer(a) and is_integer(b), do: a + b
  def tree(:add, a, b), do: {:add, a, b}

  def tree(:mul, 0, _), do: 0
  def tree(:mul, _, 0), do: 0
  def tree(:mul, 1, b), do: b
  def tree(:mul, a, 1), do: a
  def tree(:mul, a, b) when is_integer(a) and is_integer(b), do: a * b
  def tree(:mul, a, b), do: {:mul, a, b}

  def tree(:div, a, 1), do: a
  def tree(:div, _, 0), do: raise(ArgumentError, "divide by zero")
  def tree(:div, a, b) when is_integer(a) and is_integer(b), do: div(a, b)
  def tree(:div, a, b), do: {:div, a, b}

  def tree(:mod, a, _) when is_integer(a) and a < 0, do: raise(ArgumentError, "modulo of zero")
  def tree(:mod, _, b) when is_integer(b) and b <= 0, do: raise(ArgumentError, "modulo by zero")
  def tree(:mod, a, b) when is_integer(a) and is_integer(b), do: Integer.mod(a, b)
  def tree(:mod, a, b), do: {:mod, a, b}

  def tree(:eql, a, b) when is_integer(a) and is_integer(b), do: if(a == b, do: 1, else: 0)
  def tree(:eql, a, b), do: {:eql, a, b}

  def bin_op(p, op, a, b, rest) when not is_atom(b) do
    c = p[a]
    %{p | a => tree(op, c, b), instructions: rest}
  end

  def bin_op(p, op, a, b, rest) do
    bin_op(p, op, a, p[b], rest)
  end
end
