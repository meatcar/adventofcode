defmodule Day05 do
  @moduledoc """
  Moving crates between stacks
  """

  def run(part) do
    part_fn = &apply(__MODULE__, part, [&1])
    input() |> parse() |> part_fn.() |> IO.inspect(label: part)
  end

  def input, do: File.read!("inputs/05.txt")

  defmodule Move do
    defstruct [:src, :dst, :count]

    def to_string(%Move{count: count, src: src, dst: dst}) do
      "move #{count} from #{src} to #{dst}"
    end
  end

  @doc """
  Return a tuple with a map of `column index => list of crates` and a list of `%Move` structs.
  """
  def parse(s) do
    [map_str, moves_str] = String.split(s, "\n\n", trim: true)

    map =
      map_str
      |> String.split("\n")
      |> Enum.reverse()
      |> Enum.drop(1)
      |> Enum.map(fn row -> Regex.scan(~r{(\[\w\]|   ) ?}, row, capture: :all_but_first) end)
      |> Enum.reduce(%{}, fn row, map ->
        Enum.with_index(row, &{&2 + 1, &1})
        |> Enum.reduce(map, fn {i, [crate]}, map ->
          case crate do
            <<"[", c::binary-size(1), "]">> -> add_crates(map, i, [c])
            "   " -> map
          end
        end)
      end)

    moves =
      moves_str
      |> String.split("\n", trim: true)
      |> Enum.map(fn move ->
        [count, src, dst] =
          Regex.run(~r{move (\d+) from (\d+) to (\d+)$}, move, capture: :all_but_first)
          |> Enum.map(&String.to_integer/1)

        %Move{count: count, src: src, dst: dst}
      end)

    {map, moves}
  end

  def add_crates(map, i, crates), do: Map.update(map, i, crates, &(crates ++ &1))

  def remove_crates(map, i, count), do: get_and_update_in(map[i], &Enum.split(&1, count))

  def execute(_move_fn, map, []), do: map

  def execute(move_fn, map, [move | moves]) do
    execute(move_fn, move_fn.(map, move), moves)
  end

  def move_individually(map, %Move{count: count, src: src, dst: dst}) do
    Enum.reduce(Range.new(1, count), map, fn _count, map ->
      move_stack(map, %Move{count: 1, src: src, dst: dst})
    end)
  end

  def move_stack(map, %Move{count: count, src: src, dst: dst}) do
    {crates, newmap} = remove_crates(map, src, count)
    add_crates(newmap, dst, crates)
  end

  def top_crates(map) do
    IO.inspect(map)

    Map.keys(map)
    |> Enum.sort()
    |> Enum.map(fn key -> List.last(map[key]) end)
    |> Enum.join("")
  end

  @doc """
  Make moves one crate at a time.
  """
  def part1({map, moves}) do
    execute(&move_individually/2, map, moves) |> top_crates()
  end

  @doc """
  Make moves, moving a whole stack of crates at once.
  """
  def part2({map, moves}) do
    execute(&move_stack/2, map, moves) |> top_crates()
  end
end

# TESTS ====================================================

ExUnit.start(autorun: false)

defmodule Day05Test do
  use ExUnit.Case
  alias Day05, as: D

  @example """
      [D]
  [N] [C]
  [Z] [M] [P]
   1   2   3

  move 1 from 2 to 1
  move 3 from 1 to 3
  move 2 from 2 to 1
  move 1 from 1 to 2
  """

  @example2 """
  [N]     [C]
  [Z] [M] [P]
   1   2   3

  move 1 from 2 to 1
  """

  test "parse" do
    assert D.parse(@example) == {
             %{1 => ["N", "Z"], 2 => ["D", "C", "M"], 3 => ["P"]},
             [
               %D.Move{src: 2, dst: 1, count: 1},
               %D.Move{src: 1, dst: 3, count: 3},
               %D.Move{src: 2, dst: 1, count: 2},
               %D.Move{src: 1, dst: 2, count: 1}
             ]
           }

    assert D.parse(@example2) == {
             %{1 => ["N", "Z"], 2 => ["M"], 3 => ["C", "P"]},
             [
               %D.Move{src: 2, dst: 1, count: 1}
             ]
           }
  end

  test "part1" do
    assert "CMZ" == @example |> D.parse() |> D.part1()
  end

  test "part2" do
    assert "MCD" == @example |> D.parse() |> D.part2()
  end
end

case ExUnit.run() do
  %{failures: 0} ->
    Day05.run(:part1)
    Day05.run(:part2)

  _ ->
    :error
end
