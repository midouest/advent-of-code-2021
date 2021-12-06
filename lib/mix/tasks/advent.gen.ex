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
    padded_day =
      day
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    base = "day" <> padded_day

    blog = Path.join("blog", base <> ".md")
    blog_template = Path.join("_template", "blog.eex")
    Generator.copy_template(blog_template, blog, day: day)

    data = Path.join("data", base <> ".txt")
    Generator.create_file(data, "")

    lib = Path.join("lib", base <> ".ex")
    lib_template = Path.join("_template", "lib.eex")
    Generator.copy_template(lib_template, lib, day: padded_day)

    test = Path.join("test", base <> "_test.exs")
    test_template = Path.join("_template", "test.eex")
    Generator.copy_template(test_template, test, day: padded_day)
  end
end
