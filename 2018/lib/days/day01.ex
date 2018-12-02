defmodule Day01 do
  def cleanInput(input) do
    String.split(input, ~r{(, |\n)})
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  @doc """
  ### Example

      iex> Day01.part1("+1, +1, +1")
      3

      iex> Day01.part1("+1, +1, -2")
      0

      iex> Day01.part1("-1, -2, -3")
      -6

  """
  def part1(input) do
    input
    |> cleanInput
    |> Enum.reduce(fn x, acc -> acc + x end)
  end

  @doc """
  ### Example

      iex> Day01.part2("+1, -1")
      0

      iex> Day01.part2("+3, +3, +4, -2, -4")
      10

      iex> Day01.part2("-6, +3, +8, +5, -6")
      5

      iex> Day01.part2("+7, +7, -2, -7, -4")
      14

  """
  def part2(input) do
    # IO.puts("")
    input
    |> cleanInput
    |> List.to_tuple
    |> helper(%{0 => 1}, 0, 0)
  end

  def helper(tuple, map, acc, index) do
    i = Integer.mod(index, tuple_size(tuple))
    e = elem(tuple, i)
    sum = acc + e
    # IO.puts("acc: #{acc}, e: #{e}, sum: #{sum}, map[sum]: #{map[sum]}")

    case map[sum] do
      1 -> sum
      nil -> helper(tuple, Map.put(map, sum, 1), sum, i + 1)
    end
  end
end
