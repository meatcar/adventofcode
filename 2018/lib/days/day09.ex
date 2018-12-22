defmodule Day09 do
  @moduledoc """
  Advent of Code Day 09
  """

  def cleanInput(input) do
    %{"players" => players, "points" => points} =
      Regex.named_captures(
        ~r/(?<players>\d+) players; last marble is worth (?<points>\d+) points/,
        input
      )

    {String.to_integer(players), String.to_integer(points)}
  end

  @doc """
  Play the marble game with silly rules, return the highest score.

  ### Example

      iex> Day09.part1("9 players; last marble is worth 25 points")
      32
      iex> Day09.part1("10 players; last marble is worth 1618 points")
      8317
      iex> Day09.part1("13 players; last marble is worth 7999 points")
      146373
      iex> Day09.part1("17 players; last marble is worth 1104 points")
      2764
      iex> Day09.part1("21 players; last marble is worth 6111 points")
      54718
      iex> Day09.part1("30 players; last marble is worth 5807 points")
      37305

  """
  def part1(input) do
    {players, points} = cleanInput(input)
    scores = for p <- 1..players, do: {p, 0}
    circle = {[], [0]}

    {scores, _circle} =
      1..points
      |> Enum.reduce({scores, circle}, &turn/2)

    scores
    |> Enum.map(fn {_player, score} -> score end)
    |> Enum.max()
  end

  def turn(marble, {scores, circle}) when rem(marble, 23) == 0 do
    # add to score the marble, and the 7th left.
    player = Integer.mod(marble - 1, length(scores)) + 1
    {prev, [seventh | next]} = Enum.reduce(1..7, circle, fn _, circle -> left(circle) end)

    scores =
      Enum.map(scores, fn
        {p, s} when p != player -> {p, s}
        {p, s} when p == player -> {p, s + marble + seventh}
      end)

    {scores, {prev, next}}
  end

  def turn(marble, {scores, circle}) do
    # add it 2 places right
    {prev, next} = circle |> right() |> right()
    {scores, {prev, [marble | next]}}
  end

  def right({prev, [n, m | next]}) do
    {[n | prev], [m | next]}
  end

  @doc "Rotate circle one item right"
  def right({prev, [n | next]}) when next == [] do
    {[n], Enum.reverse(prev)}
  end

  def right({prev, []}) do
    {[], Enum.reverse(prev)}
  end

  @doc "Rotate circle one item left"
  def left({[p | prev], next}) do
    {prev, [p | next]}
  end

  def left({[], next}) do
    [p | prev] = Enum.reverse(next)
    {prev, [p]}
  end

  @doc """
  Same as part 1, except the max marble number is x100
  """
  def part2(input) do
    {players, points} = cleanInput(input)
    points = points * 100
    part1("#{players} players; last marble is worth #{points} points")
  end
end
