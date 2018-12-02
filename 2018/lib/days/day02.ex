defmodule Day02 do
  def cleanInput(input) do
    input
    |> String.split("\n")
  end

  @doc ~S"""
  ### Example

      iex> Day02.part1("abcdef\nbababc\nabbcde\nabcccd\naabcdd\nabcdee\nababab")
      12

  """
  def part1(input) do
    [twos, threes] =
      input
      |> cleanInput()
      |> Enum.map(&find23/1)
      |> Enum.unzip()
      |> Tuple.to_list()
      |> Enum.map(&Enum.sum/1)

    twos * threes
  end

  @doc """
  Find threes and twos
  """
  def find23(str), do: find23(String.graphemes(str), %{})
  def find23([head | tail], map), do: find23(tail, Map.update(map, head, 1, &(&1 + 1)))

  def find23([], map) do
    with values <- Map.values(map) do
      threes = if 3 in values, do: 1, else: 0
      twos = if 2 in values, do: 1, else: 0
      {twos, threes}
    end
  end

  @doc ~S"""
  ### Example

      iex> Day02.part2("abcde\nfghij\nklmno\npqrst\nfguij\naxcye\nwvxyz")
      "fgij"

  """
  def part2(input) do
    input
    |> cleanInput()
    |> loop(0)
    |> elem(0)
  end

  def loop(list, index) when index > length(list), do: {:fail, "shouldn't get this far"}

  def loop(list, index) do
    map =
      list
      |> Enum.reduce(%{}, fn str, map ->
        with str <- String.slice(str, 0, index) <> String.slice(str, (index + 1)..-1),
             do: Map.update(map, str, 1, &(&1 + 1))
      end)

    if 2 in Map.values(map) do
      Enum.find(map, fn t -> elem(t, 1) == 2 end)
    else
      loop(list, index + 1)
    end
  end
end
