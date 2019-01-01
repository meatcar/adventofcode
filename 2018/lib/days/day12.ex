defmodule Day12 do
  @moduledoc """
  Advent of Code Day 12
  """

  def cleanInput(input) do
    [state | rules] = String.split(input, "\n", trim: true)

    [_, state] = Regex.run(~r/initial state: ([.#]+)$/, state)
    state = state |> String.graphemes() |> Enum.map(&charmap/1)

    rules =
      rules
      |> Enum.map(fn s ->
        [_, input, output | _] = Regex.run(~r/^([.#]{5}) => ([.#])$/, s)
        {input |> String.graphemes() |> Enum.map(&charmap/1), charmap(output)}
      end)
      |> Enum.filter(fn {_, out} -> out == 1 end)
      |> Enum.map(fn {list, _} -> list end)
      |> make_rules()

    {state, rules}
  end

  @doc "map input chars to 1's and 0s"
  def charmap("."), do: 0
  def charmap("#"), do: 1

  @doc "make a prefix tree from rules"
  def make_rules(rules) do
    buckets =
      rules
      |> Enum.reduce({[], []}, fn
        [], buckets -> buckets
        [0 | rest], {zeroes, ones} -> {[rest | zeroes], ones}
        [1 | rest], {zeroes, ones} -> {zeroes, [rest | ones]}
      end)

    case buckets do
      {[], []} -> 1
      {[], list} -> {0, make_rules(list)}
      {list, []} -> {make_rules(list), 0}
      {zeroes, ones} -> {make_rules(zeroes), make_rules(ones)}
    end
  end

  def print_state(state) do
    state
    |> Stream.map(fn
      0 -> "."
      1 -> "#"
    end)
    |> Enum.join("")
  end

  @doc """
  Return the sums of all the indexes of pots with plants in them after
  20 generations. Each generation mutates the state according to the
  passed rules

  ### Example

      iex> Day12.part1(\"\"\"
      ...>initial state: #..#.#..##......###...###
      ...>
      ...>...## => #
      ...>..#.. => #
      ...>.#... => #
      ...>.#.#. => #
      ...>.#.## => #
      ...>.##.. => #
      ...>.#### => #
      ...>#.#.# => #
      ...>#.### => #
      ...>##.#. => #
      ...>##.## => #
      ...>###.. => #
      ...>###.# => #
      ...>####. => #
      ...>\"\"\")
      325

  """
  def part1(input) do
    {state, rules} = cleanInput(input)

    {start, state} = generations(rules, state, 20)

    state
    |> Enum.with_index(start)
    |> Enum.map(fn
      {1, n} -> n
      _ -> 0
    end)
    |> Enum.sum()
  end

  def generations(rules, state, n) do
    1..n
    |> Enum.reduce({0, state}, fn _generation, {start, state} ->
      {start, state} = prefix(start, state)
      state = apply_rules(rules, state)
      {start + 2, state}
    end)
  end

  def prefix(start, state) do
    leading_zeros = state |> Enum.take_while(fn v -> v == 0 end) |> length()

    if leading_zeros > 3 do
      {start, state}
    else
      delta = 4 - min(leading_zeros, 4)
      state = ((start - delta)..(start - 1) |> Enum.map(fn _ -> 0 end)) ++ state
      {start - delta, state}
    end
  end

  def apply_rules(_rules, []), do: []

  def apply_rules(rules, [_ | rest] = state) do
    [grow(rules, state) | apply_rules(rules, rest)]
  end

  def grow(out, _state) when is_integer(out), do: out
  def grow(rules, []), do: grow(rules, [0])
  def grow(rules, [pot | rest]), do: rules |> elem(pot) |> grow(rest)

  @doc """
  Same as part 1, except for 50 billion generations
  """
  def part2(input) do
    {state, rules} = cleanInput(input)

    a = generations(rules, state, 1000) |> sum_state()
    b = generations(rules, state, 2000) |> sum_state()
    delta = b - a
    a + (50_000_000_000 - 1000) / 1000 * delta
  end

  def sum_state({start, state}) do
    state
    |> Enum.with_index(start)
    |> Enum.map(fn
      {1, n} -> n
      _ -> 0
    end)
    |> Enum.sum()
  end
end
