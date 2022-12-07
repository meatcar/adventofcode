defmodule Day06 do
  @moduledoc """
  Sliding windows until the entire window is unique
  """

  def run(part) do
    part_fn = &apply(__MODULE__, part, [&1])
    input() |> parse() |> part_fn.() |> IO.inspect(label: part)
  end

  def input, do: File.read!("inputs/06.txt")

  def parse(s) do
    s |> String.split("\n", trim: true)
  end

  @doc """
  Return whether every item in the list is uniq. Stop eagerly, don't iterate over the whole list.
  """
  def uniq?(list) do
    Enum.reduce_while(list, %{}, fn x, map ->
      case get_and_update_in(map[x], &{&1, :found}) do
        {nil, map} -> {:cont, map}
        {:found, _} -> {:halt, nil}
      end
    end)
  end

  def find_uniq_window(input, size) do
    for signal <- input do
      index =
        signal
        |> String.graphemes()
        |> Stream.chunk_every(size, 1)
        |> Enum.find_index(&uniq?/1)

      size + index
    end
  end

  def part1(input), do: find_uniq_window(input, 4)

  def part2(input), do: find_uniq_window(input, 14)
end

# TESTS ====================================================

ExUnit.start(autorun: false)

defmodule Day06Test do
  use ExUnit.Case
  alias Day06, as: D

  @example """
  mjqjpqmgbljsphdztnvjfqwrcgsmlb
  bvwbjplbgvbhsrlpgdmjqwftvncz
  nppdvjthqldpwncqszvftbrmjlhg
  nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg
  zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw
  """

  test "parse" do
    assert D.parse(@example) == [
             "mjqjpqmgbljsphdztnvjfqwrcgsmlb",
             "bvwbjplbgvbhsrlpgdmjqwftvncz",
             "nppdvjthqldpwncqszvftbrmjlhg",
             "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg",
             "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
           ]
  end

  test "part1" do
    assert [7, 5, 6, 10, 11] == @example |> D.parse() |> D.part1()
  end

  test "part2" do
    # assert nil == @example |> D.parse() |> D.part2()
    assert [19, 23, 23, 29, 26] == @example |> D.parse() |> D.part2()
  end
end

case ExUnit.run() do
  %{failures: 0} ->
    Day06.run(:part1)
    Day06.run(:part2)

  _ ->
    :error
end
