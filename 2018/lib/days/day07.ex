defmodule Day07 do
  @moduledoc """
  Advent of Code Day 07
  """

  @alphabet [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ]

  def cleanInput(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      <<
        "Step ",
        a::binary-size(1),
        " must be finished before step ",
        b::binary-size(1),
        " can begin."
      >> = line

      {a, b}
    end)
  end

  def make_sets(list) do
    list
    |> Enum.reduce({MapSet.new(), MapSet.new()}, fn {a, b}, {as, bs} ->
      {MapSet.put(as, a), MapSet.put(bs, b)}
    end)
  end

  def next({as, bs}) do
    MapSet.difference(as, bs)
  end

  def order([]), do: []

  def order(steps) do
    step = steps |> make_sets() |> next() |> Enum.at(0)

    [step] ++
      (steps
       |> Enum.reject(fn {a, _} -> a == step end)
       |> order())
  end

  @doc """
  Resolve dependency graph.

  ### Example

      iex> Day07.part1(\"\"\"
      ...>Step C must be finished before step A can begin.
      ...>Step A must be finished before step B can begin.
      ...>Step A must be finished before step D can begin.
      ...>Step C must be finished before step F can begin.
      ...>Step B must be finished before step E can begin.
      ...>Step D must be finished before step E can begin.
      ...>Step F must be finished before step E can begin.
      ...>\"\"\")
      "CABDFE"

  """
  def part1(input) do
    steps =
      input
      |> cleanInput()

    {as, bs} = make_sets(steps)
    last = MapSet.difference(bs, as) |> Enum.sort()

    steps = last |> Enum.map(fn c -> {c, nil} end) |> Enum.concat(steps) |> Enum.sort()

    order(steps)
    |> Enum.join("")
  end

  @doc """

  ### Example

      iex> Day07.part2(\"\"\"
      ...>Step C must be finished before step A can begin.
      ...>Step A must be finished before step B can begin.
      ...>Step A must be finished before step D can begin.
      ...>Step C must be finished before step F can begin.
      ...>Step B must be finished before step E can begin.
      ...>Step D must be finished before step E can begin.
      ...>Step F must be finished before step E can begin.
      ...>\"\"\", 2, 0)
      15

  """
  def part2(input, workers \\ 5, basetime \\ 60) do
    steps =
      input
      |> cleanInput()

    {as, bs} = make_sets(steps)
    last = MapSet.difference(bs, as) |> Enum.sort()

    steps = last |> Enum.map(fn c -> {c, nil} end) |> Enum.concat(steps) |> Enum.sort()

    workers = for _ <- 1..workers, do: %{letter: nil, remaining: 0}

    {_done, second} = work(steps, workers, basetime, 0, "")
    second
  end

  def work(steps, _workers, _basetime, second, done) when steps == [], do: {done, second}

  def work(steps, workers, basetime, second, done) do
    queued = Enum.map(workers, fn %{letter: l} -> l end) |> MapSet.new()

    next = steps |> make_sets() |> next() |> MapSet.difference(queued)

    {workers, {_next, new_done}} =
      workers
      # Tick time
      |> Enum.map(fn worker ->
        if worker.remaining > 0 do
          update_in(worker.remaining, &(&1 - 1))
        else
          worker
        end
      end)
      # schedule next letters
      |> Enum.map_reduce(
        {Enum.to_list(next), ""},
        fn
          %{remaining: r} = w, {next, done} when r > 0 ->
            {w, {next, done}}

          worker, {[], done} ->
            done = done <> (worker.letter || "")
            {put_in(worker.letter, nil), {[], done}}

          worker, {[letter | next], done} ->
            done = done <> (worker.letter || "")

            worker = %{
              letter: letter,
              remaining: basetime + Enum.find_index(@alphabet, &(&1 == letter))
            }

            {worker, {next, done}}
        end
      )

    done = done <> new_done
    completed = MapSet.new(String.graphemes(new_done))
    steps = steps |> Enum.reject(fn {a, _} -> a in completed end)

    work(steps, workers, basetime, second + 1, done)
  end
end
