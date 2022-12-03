defmodule Day03 do
  @moduledoc """
  Finding shared letters within a string or between strings.
  """

  def input, do: File.read!("inputs/03.txt")

  def parse(s) do
    s
    |> String.split("\n", trim: true)
  end

  def run(part) do
    part_fn = &apply(__MODULE__, part, [&1])
    input() |> parse() |> part_fn.() |> IO.inspect(label: part)
  end

  def priority(c) when c >= ?a and c <= ?z, do: c - ?a + 1
  def priority(c) when c >= ?A and c <= ?Z, do: c - ?A + 1 + 26

  @doc """
  Split each row in half, find char not present in both, sum all of their "priorities"
  """
  def part1(input) do
    input
    |> Enum.map(fn s ->
      len = String.length(s)

      s
      |> String.split_at(div(len, 2))
      |> Tuple.to_list()
      |> Enum.map(fn s -> s |> to_charlist() |> MapSet.new() end)
      |> then(fn [l, r] -> MapSet.intersection(l, r) end)
      |> Enum.at(0)
      |> priority()
    end)
    |> Enum.sum()
  end

  @doc """
  Find char present in each three rows, sum all of their "priorities"
  """
  def part2(input) do
    input
    |> Enum.map(fn s -> s |> to_charlist() |> MapSet.new() end)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [a, b, c] ->
      MapSet.intersection(a, b) |> MapSet.intersection(c) |> Enum.at(0) |> priority()
    end)
    |> Enum.sum()
  end
end

# TESTS ====================================================

ExUnit.start(autorun: false)

defmodule Day03Test do
  use ExUnit.Case
  alias Day03, as: D

  @example ~S"""
  vJrwpWtwJgWrhcsFMMfFFhFp
  jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
  PmmdzqPrVvPwwTWBwg
  wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
  ttgJtRGJQctTZtZT
  CrZsJsPPZsGzwwsLwLmpwMDw
  """

  test "parse" do
    assert D.parse(@example) == [
             "vJrwpWtwJgWrhcsFMMfFFhFp",
             "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
             "PmmdzqPrVvPwwTWBwg",
             "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
             "ttgJtRGJQctTZtZT",
             "CrZsJsPPZsGzwwsLwLmpwMDw"
           ]
  end

  test "part1" do
    assert 157 == @example |> D.parse() |> D.part1()
  end

  test "part2" do
    assert 70 == @example |> D.parse() |> D.part2()
  end
end

case ExUnit.run() do
  %{failures: 0} ->
    Day03.run(:part1)
    Day03.run(:part2)

  _ ->
    :error
end
