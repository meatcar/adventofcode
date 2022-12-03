defmodule Day04 do
  @moduledoc """
  Comparing ranges of numbers.
  """

  def run(part) do
    part_fn = &apply(__MODULE__, part, [&1])
    input() |> parse() |> part_fn.() |> IO.inspect(label: part)
  end

  def input, do: File.read!("inputs/04.txt")

  def parse(s) do
    s
    |> String.split(~r{\D}, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(4)
  end

  @doc """
  How many ranges entirely include the other range.
  """
  def part1(input) do
    Enum.count(input, fn [a, b, x, y] ->
      (a >= x and b <= y) or (a <= x and b >= y)
    end)
  end

  @doc """
  How many ranges overlap with the other range.
  """
  def part2(input) do
    Enum.count(input, fn [a, b, x, y] ->
      b >= x and a <= y
    end)
  end
end

# TESTS ====================================================

ExUnit.start(autorun: false)

defmodule Day04Test do
  use ExUnit.Case
  alias Day04, as: D

  @example """
  2-4,6-8
  2-3,4-5
  5-7,7-9
  2-8,3-7
  6-6,4-6
  2-6,4-8
  """

  test "parse" do
    assert D.parse(@example) == [
             [2, 4, 6, 8],
             [2, 3, 4, 5],
             [5, 7, 7, 9],
             [2, 8, 3, 7],
             [6, 6, 4, 6],
             [2, 6, 4, 8]
           ]
  end

  test "part1" do
    assert 2 == @example |> D.parse() |> D.part1()
  end

  test "part2" do
    assert 4 == @example |> D.parse() |> D.part2()
  end
end

case ExUnit.run() do
  %{failures: 0} ->
    Day04.run(:part1)
    Day04.run(:part2)

  _ ->
    :error
end
