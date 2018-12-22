defmodule Day08 do
  @moduledoc """
  Advent of Code Day 08
  """

  def cleanInput(input) do
    input
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Take a string of numbers that represents a tree, like
  "num_kids num_meta [..kids..] [..meta..]",
  Return a sum of all the meta of all the nodes

  ### Example

      iex> Day08.part1("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
      138

  """
  def part1(input) do
    {root, _} =
      input
      |> cleanInput()
      |> get_node()

    sum_meta(root)
  end

  def get_node([n_kids, n_meta | list]) do
    {kids, list} =
      if n_kids == 0,
        do: {[], list},
        else: Enum.map_reduce(1..n_kids, list, fn _, list -> get_node(list) end)

    {meta, list} = Enum.split(list, n_meta)

    {%{kids: kids, meta: meta}, list}
  end

  def sum_meta(root) do
    root.kids
    |> Enum.map(&sum_meta/1)
    |> Enum.concat(root.meta)
    |> Enum.sum()
  end

  @doc """
  Take a string of numbers that represents a tree, like
  "num_kids num_meta [..kids..] [..meta..]",
  Calculate the value of the root, where the value of a node is the
  sum of the meta if there's no kids, otherwise the sum of the value
  of all the children indexed by the meta.

  ### Example

      iex> Day08.part2("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
      66

  """
  def part2(input) do
    {root, _} =
      input
      |> cleanInput()
      |> get_node()

    sum_node(root)
  end

  def sum_node(root) do
    case root.kids do
      [] ->
        Enum.sum(root.meta)

      _ ->
        n_kids = length(root.kids)

        root.meta
        |> Enum.reject(fn i -> i > n_kids end)
        |> Enum.map(fn i -> root.kids |> Enum.at(i - 1) |> sum_node() end)
        |> Enum.sum()
    end
  end
end
