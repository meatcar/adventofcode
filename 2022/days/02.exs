defmodule Day02 do
  @moduledoc """
  Play rock-paper scissors.
  """

  def input, do: File.read!("inputs/02.txt")

  def parse(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
  end

  def run(part) do
    part_fn = &apply(__MODULE__, part, [&1])
    input() |> parse() |> part_fn.() |> IO.inspect(label: part)
  end

  @op_move %{"A" => :r, "B" => :p, "C" => :s}
  @my_move %{"X" => :r, "Y" => :p, "Z" => :s}
  @move_score %{:r => 1, :p => 2, :s => 3}
  @result_scores [
    [:r, :r, 3],
    [:p, :p, 3],
    [:s, :s, 3],
    [:r, :p, 6],
    [:p, :s, 6],
    [:s, :r, 6],
    [:r, :s, 0],
    [:p, :r, 0],
    [:s, :p, 0]
  ]

  def get_result_score(op, me) do
    Enum.find_value(
      @result_scores,
      fn [o, m, v] ->
        if o == op and m == me, do: v
      end
    )
  end

  @doc """
  Given a list of opponent and own, return total own-move score + game result score.
  """
  def part1(input) do
    input
    |> Enum.map(fn [op, me] -> [@op_move[op], @my_move[me]] end)
    |> Enum.map(fn [op, me] ->
      @move_score[me] + get_result_score(op, me)
    end)
    |> Enum.sum()
  end

  @my_result %{"X" => 0, "Y" => 3, "Z" => 6}

  def get_my_move(op, result) do
    Enum.find_value(
      @result_scores,
      fn [o, m, v] ->
        if o == op and v == result, do: m
      end
    )
  end

  @doc """
  Given list of opponent moves and desired results, return total own-move score + game result score.
  """
  def part2(input) do
    input
    |> Enum.map(fn [op, me] -> [@op_move[op], @my_result[me]] end)
    |> Enum.map(fn [op, result] ->
      result + @move_score[get_my_move(op, result)]
    end)
    |> Enum.sum()
  end
end

# TESTS ====================================================

ExUnit.start(autorun: false)

defmodule Day02Test do
  use ExUnit.Case
  alias Day02, as: D

  @example ~S"""
  A Y
  B X
  C Z
  """

  test "parse" do
    assert D.parse(@example) == [
             ["A", "Y"],
             ["B", "X"],
             ["C", "Z"]
           ]
  end

  test "part1" do
    assert 15 == @example |> D.parse() |> D.part1()
  end

  test "part2" do
    assert 12 == @example |> D.parse() |> D.part2()
  end
end

case ExUnit.run() do
  %{failures: 0} ->
    Day02.run(:part1)
    Day02.run(:part2)

  _ ->
    :error
end
