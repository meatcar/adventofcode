defmodule Day07 do
  @moduledoc """
  Parse shell output into a file tree
  """

  def run(part) do
    part_fn = &apply(__MODULE__, part, [&1])
    input() |> parse() |> part_fn.() |> IO.inspect(label: part)
  end

  def input, do: File.read!("inputs/07.txt")

  def parse(s) do
    s
    |> String.splitter("\n", trim: true)
    |> Enum.reduce({%{}, []}, fn line, {map, cwd} ->
      case line do
        "$ cd .." ->
          {map, List.delete_at(cwd, -1)}

        <<"$ cd ", rest::binary>> ->
          cwd = cwd ++ [rest]
          {update_in(map, cwd, &(&1 || %{})), cwd}

        "$ ls" ->
          {map, cwd}

        <<"dir ", rest::binary>> ->
          {update_in(map, cwd ++ [rest], &(&1 || %{})), cwd}

        line ->
          [size, filename] = Regex.run(~r{^(\d+) (.+)$}, line, capture: :all_but_first)
          {update_in(map, cwd ++ [filename], fn _ -> String.to_integer(size) end), cwd}
      end
    end)
    |> then(fn {map, _cwd} -> map end)
  end

  def get_dir_size(size) when is_integer(size), do: size

  def get_dir_size(dir) do
    dir |> Map.values() |> Enum.map(&get_dir_size/1) |> Enum.sum()
  end

  def flatten_dirs(map, path \\ "@") do
    Enum.reduce(map, %{}, fn
      {_, size}, map when is_integer(size) ->
        map

      {name, dir}, map when is_map(dir) ->
        path = "#{path}/#{name}"
        size = get_dir_size(dir)
        subdirs = flatten_dirs(dir, path)

        map
        |> Map.put(path, size)
        |> Map.merge(subdirs)
    end)
  end

  @doc """
  Get total size of dirs that are individually less than 100_000 in size. duplicates allowed.
  """
  def part1(input) do
    input
    |> flatten_dirs()
    |> Enum.map(fn
      {_, size} when size < 100_000 -> size
      _ -> 0
    end)
    |> Enum.sum()
  end

  @doc """
  Get the size of the smallest directory to be deleted to satisfy a free space requirement.
  """
  def part2(input) do
    free_space = 70_000_000 - get_dir_size(input)
    space_required = 30_000_000 - free_space

    input
    |> flatten_dirs()
    |> Enum.sort_by(fn {_, s} -> s end)
    |> Enum.find(fn {_, s} -> s >= space_required end)
    |> then(fn {_, s} -> s end)
  end
end

# TESTS ====================================================

ExUnit.start(autorun: false)

defmodule Day07Test do
  use ExUnit.Case
  alias Day07, as: D

  @example """
  $ cd /
  $ ls
  dir a
  14848514 b.txt
  8504156 c.dat
  dir d
  $ cd a
  $ ls
  dir e
  29116 f
  2557 g
  62596 h.lst
  $ cd e
  $ ls
  584 i
  $ cd ..
  $ cd ..
  $ cd d
  $ ls
  4060174 j
  8033020 d.log
  5626152 d.ext
  7214296 k
  """

  test "parse" do
    assert D.parse(@example) ==
             %{
               "/" => %{
                 "a" => %{
                   "e" => %{
                     "i" => 584
                   },
                   "f" => 29116,
                   "g" => 2557,
                   "h.lst" => 62596
                 },
                 "b.txt" => 14_848_514,
                 "c.dat" => 8_504_156,
                 "d" => %{
                   "d.ext" => 5_626_152,
                   "d.log" => 8_033_020,
                   "j" => 4_060_174,
                   "k" => 7_214_296
                 }
               }
             }
  end

  test "part1" do
    assert 95437 == @example |> D.parse() |> D.part1()
  end

  test "part2" do
    assert 24_933_642 == @example |> D.parse() |> D.part2()
  end
end

case ExUnit.run() do
  %{failures: 0} ->
    Day07.run(:part1)
    Day07.run(:part2)

  _ ->
    :error
end
