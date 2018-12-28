defmodule Day10 do
  @moduledoc """
  Advent of Code Day 10
  """

  def cleanInput(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      [str | rest] =
        Regex.run(
          ~r/position=< ?(-?\d+),  ?(-?\d+)> velocity=< ?(-?\d+),  ?(-?\d+)>/,
          str
        )

      [x, y, dx, dy] = Enum.map(rest, &String.to_integer/1)
      {{x, y}, {dx, dy}}
    end)
  end

  def dimensions(points) do
    min =
      Enum.reduce(points, {nil, nil}, fn {{x, y}, _}, {mx, my} -> {min(x, mx), min(y, my)} end)

    max = Enum.reduce(points, {0, 0}, fn {{x, y}, _}, {mx, my} -> {max(x, mx), max(y, my)} end)

    {min, max}
  end

  @doc """
  Iterate the given points & velocities, one second at a time, until a message appears.

  ### Example

    iex> Day10.part1(\"\"\"
    ...>position=< 9,  1> velocity=< 0,  2>
    ...>position=< 7,  0> velocity=<-1,  0>
    ...>position=< 3, -2> velocity=<-1,  1>
    ...>position=< 6, 10> velocity=<-2, -1>
    ...>position=< 2, -4> velocity=< 2,  2>
    ...>position=<-6, 10> velocity=< 2, -2>
    ...>position=< 1,  8> velocity=< 1, -1>
    ...>position=< 1,  7> velocity=< 1,  0>
    ...>position=<-3, 11> velocity=< 1, -2>
    ...>position=< 7,  6> velocity=<-1, -1>
    ...>position=<-2,  3> velocity=< 1,  0>
    ...>position=<-4,  3> velocity=< 2,  0>
    ...>position=<10, -3> velocity=<-1,  1>
    ...>position=< 5, 11> velocity=< 1, -2>
    ...>position=< 4,  7> velocity=< 0, -1>
    ...>position=< 8, -2> velocity=< 0,  1>
    ...>position=<15,  0> velocity=<-2,  0>
    ...>position=< 1,  6> velocity=< 1,  0>
    ...>position=< 8,  9> velocity=< 0, -1>
    ...>position=< 3,  3> velocity=<-1,  1>
    ...>position=< 0,  5> velocity=< 0, -1>
    ...>position=<-2,  2> velocity=< 2,  0>
    ...>position=< 5, -2> velocity=< 1,  2>
    ...>position=< 1,  4> velocity=< 2,  1>
    ...>position=<-2,  7> velocity=< 2, -2>
    ...>position=< 3,  6> velocity=<-1, -1>
    ...>position=< 5,  0> velocity=< 1,  0>
    ...>position=<-6,  0> velocity=< 2,  0>
    ...>position=< 5,  9> velocity=< 1, -2>
    ...>position=<14,  7> velocity=<-2,  0>
    ...>position=<-3,  6> velocity=< 2, -1>
    ...>\"\"\")
    "@...@..@@@\\n@...@...@.\\n@...@...@.\\n@@@@@...@.\\n@...@...@.\\n@...@...@.\\n@...@...@.\\n@...@..@@@"

  """
  def part1(input) do
    points = cleanInput(input)
    {_second, points} = tick(points, 0)
    # IO.write(points)
    points
  end

  def tick(points, second) do
    new_points = points |> move_points()

    if area(points) <= area(new_points) do
      {second, draw_points(points)}
    else
      tick(new_points, second + 1)
    end
  end

  def move_points(points) do
    Enum.map(points, fn {{x, y}, {dx, dy}} -> {{x + dx, y + dy}, {dx, dy}} end)
  end

  def area(points) do
    {{xmin, ymin}, {xmax, ymax}} = dimensions(points)
    (xmax - xmin) * (ymax - ymin)
  end

  def draw_points(points) do
    {{xmin, ymin}, {xmax, ymax}} = dimensions(points)

    raw_points = Enum.map(points, fn {p, _v} -> p end)

    for y <- ymin..ymax do
      for x <- xmin..xmax do
        if({x, y} in raw_points) do
          "@"
        else
          "."
        end
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")
  end

  @doc """
  Same as part one, just get the number of seconds

  ### Example

    iex> Day10.part2(\"\"\"
    ...>position=< 9,  1> velocity=< 0,  2>
    ...>position=< 7,  0> velocity=<-1,  0>
    ...>position=< 3, -2> velocity=<-1,  1>
    ...>position=< 6, 10> velocity=<-2, -1>
    ...>position=< 2, -4> velocity=< 2,  2>
    ...>position=<-6, 10> velocity=< 2, -2>
    ...>position=< 1,  8> velocity=< 1, -1>
    ...>position=< 1,  7> velocity=< 1,  0>
    ...>position=<-3, 11> velocity=< 1, -2>
    ...>position=< 7,  6> velocity=<-1, -1>
    ...>position=<-2,  3> velocity=< 1,  0>
    ...>position=<-4,  3> velocity=< 2,  0>
    ...>position=<10, -3> velocity=<-1,  1>
    ...>position=< 5, 11> velocity=< 1, -2>
    ...>position=< 4,  7> velocity=< 0, -1>
    ...>position=< 8, -2> velocity=< 0,  1>
    ...>position=<15,  0> velocity=<-2,  0>
    ...>position=< 1,  6> velocity=< 1,  0>
    ...>position=< 8,  9> velocity=< 0, -1>
    ...>position=< 3,  3> velocity=<-1,  1>
    ...>position=< 0,  5> velocity=< 0, -1>
    ...>position=<-2,  2> velocity=< 2,  0>
    ...>position=< 5, -2> velocity=< 1,  2>
    ...>position=< 1,  4> velocity=< 2,  1>
    ...>position=<-2,  7> velocity=< 2, -2>
    ...>position=< 3,  6> velocity=<-1, -1>
    ...>position=< 5,  0> velocity=< 1,  0>
    ...>position=<-6,  0> velocity=< 2,  0>
    ...>position=< 5,  9> velocity=< 1, -2>
    ...>position=<14,  7> velocity=<-2,  0>
    ...>position=<-3,  6> velocity=< 2, -1>
    ...>\"\"\")
    3
  """
  def part2(input) do
    points = cleanInput(input)
    {second, _points} = tick(points, 0)
    second
  end
end
