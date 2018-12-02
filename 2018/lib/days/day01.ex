defmodule Day01 do
  @moduledoc """
  Advent of Code Day 1
  """

  def cleanInput(input) do
    input
    |> String.split(~r{(, |\n)})
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  @doc """
  Sum

  ### Example

      iex> Day01.part1("+1, +1, +1")
      3

      iex> Day01.part1("+1, +1, -2")
      0

      iex> Day01.part1("-1, -2, -3")
      -6

  """
  def part1(input) do
    input
    |> cleanInput
    |> Enum.reduce(fn x, acc -> acc + x end)
  end

  @doc """
  Keep a rolling sum, return the first sum hit twice.

  ### Example

      iex> Day01.part2("+1, -1")
      0

      iex> Day01.part2("+3, +3, +4, -2, -4")
      10

      iex> Day01.part2("-6, +3, +8, +5, -6")
      5

      iex> Day01.part2("+7, +7, -2, -7, -4")
      14

  """
  def part2(input) do
    input
    |> cleanInput
    |> List.to_tuple()
    |> helper(%{0 => 1}, 0, 0)
  end

  def helper(tuple, map, acc, index) do
    i = Integer.mod(index, tuple_size(tuple))
    e = elem(tuple, i)
    sum = acc + e

    case map[sum] do
      1 -> sum
      nil -> helper(tuple, Map.put(map, sum, 1), sum, i + 1)
    end
  end
end
