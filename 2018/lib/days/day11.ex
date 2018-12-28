defmodule Day11 do
  @moduledoc """
  Advent of Code Day 11
  """

  def cleanInput(input) do
    input
    |> String.to_integer()
  end

  @doc """
  Return the top-left {x, y} coords of the 3x3 square with the highest total power.

  ### Example

      iex> Day11.part1("18")
      {33, 45}

      iex> Day11.part1("42")
      {21, 61}

  """
  def part1(input) do
    serial = cleanInput(input)

    points =
      for(
        y <- 1..300,
        x <- 1..300,
        do: {{x, y}, get_power({x, y}, serial)}
      )
      |> Enum.reduce(%{}, fn {point, power}, map -> Map.put(map, point, power) end)

    sums =
      for y <- 1..298, x <- 1..298 do
        sum =
          for(x <- x..(x + 2), y <- y..(y + 2), do: Map.get(points, {x, y}))
          |> Enum.sum()

        {{x, y}, sum}
      end

    {p, _sum} = Enum.max_by(sums, fn {_p, sum} -> sum end)
    p
  end

  @doc """

  ### Example

      iex> Day11.get_power({3, 5}, 8)
      4

      iex> Day11.get_power({122, 79}, 57)
      -5

      iex> Day11.get_power({217, 196}, 39)
      0

      iex> Day11.get_power({101, 153}, 71)
      4

  """
  def get_power({x, y}, serial) do
    id = x + 10
    power = (id * y + serial) * id

    hundreds =
      if power < 100, do: 0, else: power |> to_string() |> String.at(-3) |> String.to_integer()

    hundreds - 5
  end

  @doc """
  Return {{x, y}, size}, the top-left {x, y} coords of the size*size square with the highest total power.

  ### Example

  Takes~ 8s/test

      # iex> Day11.part2("18")
      # {{90, 269}, 16}

      # iex> Day11.part2("42")
      # {{232, 251}, 12}

  """
  def part2(input) do
    serial = cleanInput(input)

    pointStream =
      Stream.unfold(
        {1, 1},
        fn
          {x, _y} when x == 301 -> nil
          {x, y} = p when y == 300 -> {p, {x + 1, 1}}
          {x, y} = p -> {p, {x, y + 1}}
        end
      )

    # summed-area table
    areas =
      pointStream
      |> Enum.reduce(%{}, fn {x, y}, table ->
        # point + top + left - topleft
        top = if y == 1, do: 0, else: Map.get(table, {x, y - 1})
        left = if x == 1, do: 0, else: Map.get(table, {x - 1, y})
        topleft = if x == 1 or y == 1, do: 0, else: Map.get(table, {x - 1, y - 1})

        sum = get_power({x, y}, serial) + top + left - topleft

        Map.put(table, {x, y}, sum)
      end)

    {{p, size}, _sum} =
      pointStream
      |> Stream.flat_map(fn p -> squares_at_point(p, areas) end)
      |> Enum.max_by(fn {_, sum} -> sum end)

    {p, size}
  end

  def squares_at_point({x, y} = p, areas) do
    1..(301 - max(x, y))
    |> Stream.map(fn size -> {{p, size}, area_at_point(p, size, areas)} end)
  end

  @doc """
  # Example

      iex> Day11.area_at_point({1, 1}, 1, %{{1, 1} => 1})
      1

  """
  def area_at_point({x, y}, size, areas) do
    delta = size - 1
    top = if y == 1, do: 0, else: Map.get(areas, {x + delta, y - 1})
    left = if x == 1, do: 0, else: Map.get(areas, {x - 1, y + delta})
    topleft = if x == 1 or y == 1, do: 0, else: Map.get(areas, {x - 1, y - 1})

    Map.get(areas, {x + delta, y + delta}) - top - left + topleft
  end
end
