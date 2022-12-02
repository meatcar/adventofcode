defmodule Day01 do
  def input() do
    File.read!("inputs/01.txt")
  end

  def parse(s) do
    s
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn s ->
      s
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def part1(input) do
    input
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  def part2(input) do
    input
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.sum()
  end
end

ExUnit.start(autorun: false)

defmodule Day01Test do
  use ExUnit.Case
  alias Day01, as: D
  @test_str ~S"""
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    """

  test "parse" do
    s = """
      1
      2

      3
      4
      """
    assert D.parse(s) == [[1, 2], [3, 4]]
  end

  test "part1" do
    assert 24000 == @test_str |> D.parse() |> D.part1()
  end

  test "part2" do
    assert 45000 == @test_str |> D.parse() |> D.part2()
  end
end

case ExUnit.run() do
  %{failures: 0} ->
    input = Day01.input()
      |> Day01.parse()

    input
    |> Day01.part1()
    |> IO.inspect(label: "part1")

    input
    |> Day01.part2()
    |> IO.inspect(label: "part2")

  _ ->
    :error
end
