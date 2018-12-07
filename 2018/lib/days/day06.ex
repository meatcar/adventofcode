defmodule Day06 do
  @moduledoc """
  Advent of Code Day 06
  """

  def cleanInput(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ", "))
    |> Enum.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def dimensions(points) do
    Enum.reduce(
      points,
      {{nil, nil}, {0, 0}},
      fn {x, y}, {{minx, miny}, {maxx, maxy}} ->
        {{min(x, minx), min(y, miny)}, {max(x, maxx), max(y, maxy)}}
      end
    )
  end

  @doc """
  Return the closest points to a from all points in list. Nil if tied.
  """
  def closest(a, list) do
    {_, candidates} =
      list
      |> Enum.group_by(fn b -> distance(a, b) end)
      |> Enum.min_by(fn {d, _} -> d end)

    case candidates do
      [p] -> p
      _ -> nil
    end
  end

  @doc """
  Return the largest area around a point.

  ### Example

      iex> Day06.part1(\"\"\"
      ...>1, 1
      ...>1, 6
      ...>8, 3
      ...>3, 4
      ...>5, 5
      ...>8, 9
      ...>\"\"\")
      17

  """
  def part1(input) do
    points =
      input
      |> cleanInput()

    {{minx, miny}, {maxx, maxy}} = dimensions(points)

    field =
      for(x <- minx..maxx, y <- miny..maxy, do: {{x, y}, closest({x, y}, points)})
      |> Enum.reduce(%{}, fn
        {_, nil}, map -> map
        {p, point}, map -> Map.put(map, p, point)
      end)

    borders =
      [
        for(x <- minx..maxx, do: {x, miny}),
        for(x <- minx..maxx, do: {x, maxy}),
        for(y <- miny..maxy, do: {minx, y}),
        for(y <- miny..maxy, do: {maxx, y})
      ]
      |> List.flatten()
      |> Enum.reduce(MapSet.new(), &MapSet.put(&2, get_in(field, [&1])))

    borders
    |> Enum.reduce(field, &Map.delete(&2, &1))
    |> Enum.reduce(%{}, fn {_, p}, map -> Map.update(map, p, 1, &(&1 + 1)) end)
    |> Map.values()
    |> Enum.max()
  end

  @doc """
  Return the size of the area where the sum of the distances to all points is less than max_sum

  ### Example

      iex> Day06.part2(\"\"\"
      ...>1, 1
      ...>1, 6
      ...>8, 3
      ...>3, 4
      ...>5, 5
      ...>8, 9
      ...>\"\"\", 32)
      16

  """
  def part2(input, max_sum \\ 10000) do
    points =
      input
      |> cleanInput()

    {{minx, miny}, {maxx, maxy}} = dimensions(points)

    for(x <- minx..maxx, y <- miny..maxy, do: {x, y})
    |> Enum.reduce(%{}, fn p, map ->
      Map.put(map, p, points |> Enum.map(&distance(&1, p)) |> Enum.sum())
    end)
    |> Map.values()
    |> Enum.filter(&(&1 < max_sum))
    |> Enum.count()
  end
end
