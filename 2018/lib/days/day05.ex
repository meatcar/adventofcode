defmodule Day05 do
  @moduledoc """
  Advent of Code Day 05
  """

  def cleanInput(input) do
    input
  end

  @doc """
  Keep on removing all adjacent mix-cased pairs, until there are no
  more left. Return the length of that string.

  ### Example

      iex> Day05.part1("dabAcCaCBAcCcaDA")
      10

  """
  def part1(input) do
    input
    |> react_all()
    |> String.length()
  end

  def react_all(str) do
    str
    |> String.graphemes()
    |> react_all([])
    |> Enum.reverse()
    |> List.to_string()
  end

  defp react_all(list, prev) when list == [], do: prev
  defp react_all([c], prev), do: [c | prev]

  defp react_all([a, b | rest], prev) do
    if react?(a, b) do
      {p, prev} = List.pop_at(prev, 0)

      if p do
        react_all([p | rest], prev)
      else
        react_all(rest, prev)
      end
    else
      react_all([b | rest], [a | prev])
    end
  end

  def react?(a, b), do: a != b and (a == String.upcase(b) or a == String.downcase(b))

  @doc """
  Return the length of the smallest "reacted" string that can be made
  if you remove all instances of some letter from the input.

  ### Example

      iex> Day05.part2("dabAcCaCBAcCcaDA")
      4

  """
  def part2(input) do
    input
    |> String.graphemes()
    |> Enum.uniq_by(&String.downcase/1)
    |> Enum.map(fn c ->
      input
      |> String.replace(Regex.compile!(c, "i"), "", global: true)
      |> react_all()
      |> String.length()
    end)
    |> Enum.min()
  end
end
