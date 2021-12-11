defmodule Mix.Tasks.Advent.Gen do
  @moduledoc """
  Generate the solution, puzzle input, test and blog files for the next day of
  Advent of Code.

  ## Files

  The following files will be generated:

  - `blog/dayXX.md` - Solution postmortem
  - `data/dayXX.txt` - Puzzle input
  - `lib/dayXX.ex` - Puzzle solution
  - `test/dayXX.ex` - Puzzle example unit tests

  ## Suffix

  The `XX` suffix in the generated files is the number of the next day, padded
  with a leading zero.

  If no days have been generated yet, the first day will be `01`. Subsequent
  calls to `mix advent.gen` will increment the previous day. For example, if
  day `01` has been generated, then the next day will be day `02`.
  """

  @shortdoc "Generate Advent of Code files"

  use Mix.Task

  alias Mix.Generator

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:mojito)

    File.ls!("lib")
    |> Stream.filter(&String.starts_with?(&1, "day"))
    |> Enum.to_list()
    |> Enum.sort()
    |> List.last(0)
    |> String.slice(3..4)
    |> String.to_integer()
    |> Kernel.+(1)
    |> generate()
  end

  def generate(day) do
    padded = Advent.pad_day(day)
    base = "day" <> padded

    copy_template("blog", base <> ".md", day: day)

    token = System.get_env("AOC_SESSION_TOKEN")

    content =
      if token != nil do
        {:ok, response} =
          Mojito.get(~s"https://adventofcode.com/2021/day/#{day}/input", [
            {"Cookie", ~s"session=#{token}"}
          ])

        String.trim(response.body)
      else
        ""
      end

    Path.join("data", base <> ".txt")
    |> Generator.create_file(content)

    copy_template("lib", base <> ".ex", day: padded)

    modules =
      1..(day - 1)
      |> Stream.map(&(format_module(&1) <> ","))
      |> Enum.concat([format_module(day)])

    copy_template("puzzles", "lib", "puzzles.ex", [modules: modules], force: true)

    copy_template("test", base <> "_test.exs", day: padded)
  end

  def copy_template(src, dest_dir \\ nil, dest, assigns, options \\ []) do
    dest_dir = if dest_dir == nil, do: src, else: dest_dir
    src_path = Path.join("_template", src <> ".eex")
    dest_path = Path.join(dest_dir, dest)
    Generator.copy_template(src_path, dest_path, assigns, options)
  end

  def format_module(day) do
    padded = Advent.pad_day(day)
    ~s"Advent.Day#{padded}"
  end
end
