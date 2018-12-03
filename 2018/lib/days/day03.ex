defmodule Day03 do
  @moduledoc """
  Advent of Code Day 3
  """

  def cleanInput(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn str ->
      with [_fullmatch | matches] <-
             Regex.run(
               ~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/,
               str
             ),
           [id, left, top, width, height] <- Enum.map(matches, &String.to_integer/1) do
        %{id: id, top: top, left: left, width: width, height: height}
      end
    end)
  end

  @doc ~S"""
  Return a sum of of the areas of all intersections of two or more rectangles

  ### Example

      iex> Day03.part1("#1 @ 1,3: 4x4\n#2 @ 3,1: 4x4\n#3 @ 5,5: 2x2")
      4

  """
  def part1(input) do
    squares = cleanInput(input)

    sets =
      squares
      |> Enum.map(&to_set/1)

    MapSet.size(get_all_intersections(sets))
  end

  @doc """
    Turn a square into a set of "XxY" coordinates
  """
  def to_set(%{left: left, top: top, height: height, width: width}) do
    for(
      y <- (top + 1)..(top + height),
      x <- (left + 1)..(left + width),
      do: "#{x}x#{y}"
    )
    |> Enum.reduce(MapSet.new(), fn p, set -> MapSet.put(set, p) end)
  end

  @doc """
  Return a set of all coordinates where two or more sets intersect
  """
  def get_all_intersections(sets), do: get_all_intersections(sets, MapSet.new(), MapSet.new())
  def get_all_intersections(sets, _, intersections) when length(sets) == 0, do: intersections

  def get_all_intersections([set | sets], union, intersections) do
    get_all_intersections(
      sets,
      MapSet.union(union, set),
      MapSet.union(intersections, MapSet.intersection(union, set))
    )
  end

  @doc ~S"""
  Return the id of the rectangle that intersects no others.

  ### Example

      iex> Day03.part2("#1 @ 1,3: 4x4\n#2 @ 3,1: 4x4\n#3 @ 5,5: 2x2")
      3

  """
  def part2(input) do
    squares =
      cleanInput(input)
      |> Enum.map(fn sq -> {sq.id, to_set(sq)} end)

    {id, _} =
      Enum.find(squares, fn {id, set} ->
        # find a square that intersects no others
        Enum.all?(squares, fn
          # skip yourself
          {id2, _} when id == id2 -> true
          {_, set2} -> MapSet.intersection(set, set2) |> MapSet.size() == 0
        end)
      end)

    id
  end
end
