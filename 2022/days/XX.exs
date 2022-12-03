defmodule DayXX do
  @moduledoc """
  Template day
  """

  def run(part) do
    part_fn = &apply(__MODULE__, part, [&1])
    input() |> parse() |> part_fn.() |> IO.inspect(label: part)
  end

  def input, do: File.read!("inputs/XX.txt")

  def parse(s) do
    s
  end

  @doc """
  """
  def part1(input) do
    nil
  end

  @doc """
  """
  def part2(input) do
    nil
  end
end

# TESTS ====================================================

ExUnit.start(autorun: false)

defmodule DayXXTest do
  use ExUnit.Case
  alias DayXX, as: D

  @example """
  """

  test "parse" do
    assert D.parse(@example) == []
  end

  test "part1" do
    assert nil == @example |> D.parse() |> D.part1()
  end

  test "part2" do
    assert nil == @example |> D.parse() |> D.part2()
  end
end

case ExUnit.run() do
  %{failures: 0} ->
    DayXX.run(:part1)
    DayXX.run(:part2)

  _ ->
    :error
end
