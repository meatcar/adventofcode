defmodule Day04 do
  @moduledoc """
  Advent of Code Day 04
  """

  def cleanInput(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.sort()
    |> Enum.map(fn s ->
      [_ | [date, hour, minute, action]] =
        Regex.run(~r/^\[(\d{4}-\d{2}-\d{2}) (\d{2}):(\d{2})\] (.+)$/, s)

      %{
        date: Date.from_iso8601!(date),
        hour: String.to_integer(hour),
        minute: String.to_integer(minute),
        action: parse_action(action)
      }
    end)
    |> make_guards(%{}, nil)
    |> Enum.map(fn {_, guard = %{shifts: shifts}} ->
      with slept <-
             shifts
             |> Enum.map(&Enum.concat(&1.sleep))
             |> List.flatten(),
           freq <- Enum.reduce(slept, %{}, fn n, map -> Map.update(map, n, 1, &(&1 + 1)) end),
           do: Map.put(guard, :freq, freq)
    end)
  end

  def parse_action("falls asleep"), do: :sleeps
  def parse_action("wakes up"), do: :wakes

  def parse_action(str) do
    [_ | [id]] = Regex.run(~r/Guard #(\d+) begins shift/, str)
    {:guard, String.to_integer(id)}
  end

  def make_guards(logs, guards, _state) when logs === [], do: guards

  def make_guards([_log = %{action: {:guard, id}} | logs], guards, _state) do
    guards = Map.put_new(guards, id, %{id: id, shifts: []})
    guards = update_in(guards[id].shifts, &[%{sleep: []} | &1])
    make_guards(logs, guards, {id, :awake})
  end

  def make_guards([log = %{action: :sleeps} | logs], guards, {id, :awake}),
    do: make_guards(logs, guards, {id, :sleeping, log.minute})

  def make_guards([log = %{action: :wakes} | logs], guards, {id, :sleeping, start}) do
    make_guards(
      logs,
      update_in(guards[id].shifts, fn [shift | shifts] ->
        [
          %{shift | sleep: [start..(log.minute - 1) | shift.sleep]}
          | shifts
        ]
      end),
      {id, :awake}
    )
  end

  @doc """
  Find the guard that sleeps the most, return his "most often asleep" minute * guardId

  ### Example

      iex> Day04.part1(\"\"\"
      ...>[1518-11-01 00:05] falls asleep
      ...>[1518-11-01 00:25] wakes up
      ...>[1518-11-01 00:55] wakes up
      ...>[1518-11-01 23:58] Guard #99 begins shift
      ...>[1518-11-02 00:40] falls asleep
      ...>[1518-11-02 00:50] wakes up
      ...>[1518-11-03 00:05] Guard #10 begins shift
      ...>[1518-11-03 00:24] falls asleep
      ...>[1518-11-03 00:29] wakes up
      ...>[1518-11-05 00:03] Guard #99 begins shift
      ...>[1518-11-04 00:36] falls asleep
      ...>[1518-11-04 00:02] Guard #99 begins shift
      ...>[1518-11-04 00:46] wakes up
      ...>[1518-11-01 00:30] falls asleep
      ...>[1518-11-05 00:45] falls asleep
      ...>[1518-11-05 00:55] wakes up
      ...>[1518-11-01 00:00] Guard #10 begins shift
      ...>\"\"\")
      240

  """
  def part1(input) do
    guards =
      input
      |> cleanInput()

    {id, {day, _}} =
      guards
      |> Enum.map(fn %{id: id, freq: freq} ->
        {id,
         Enum.reduce(freq, {0, 0}, fn {day, count}, {max, sum} ->
           {
             if(count > (freq[max] || 0), do: day, else: max),
             sum + count
           }
         end)}
      end)
      |> Enum.max_by(fn {_, {_, sum}} -> sum end)

    id * day
  end

  @doc """
  Find the guard that has the "most frequently slept" minute, return that minute * guardId

  ### Example

      iex> Day04.part2(\"\"\"
      ...>[1518-11-01 00:00] Guard #10 begins shift
      ...>[1518-11-01 00:05] falls asleep
      ...>[1518-11-01 00:25] wakes up
      ...>[1518-11-01 00:30] falls asleep
      ...>[1518-11-01 00:55] wakes up
      ...>[1518-11-01 23:58] Guard #99 begins shift
      ...>[1518-11-02 00:40] falls asleep
      ...>[1518-11-02 00:50] wakes up
      ...>[1518-11-03 00:05] Guard #10 begins shift
      ...>[1518-11-03 00:24] falls asleep
      ...>[1518-11-03 00:29] wakes up
      ...>[1518-11-04 00:02] Guard #99 begins shift
      ...>[1518-11-04 00:36] falls asleep
      ...>[1518-11-04 00:46] wakes up
      ...>[1518-11-05 00:03] Guard #99 begins shift
      ...>[1518-11-05 00:45] falls asleep
      ...>[1518-11-05 00:55] wakes up
      ...>\"\"\")
      4455

  """
  def part2(input) do
    guards =
      input
      |> cleanInput()

    meta_frequency =
      guards
      |> Enum.reduce(%{}, fn guard, meta ->
        for {day, count} <- guard.freq, into: meta do
          with v = {meta_count, _} <- meta[day] || {0, nil} do
            if count > meta_count,
              do: {day, {count, guard.id}},
              else: {day, v}
          end
        end
      end)

    {day, {_count, id}} =
      meta_frequency
      |> Enum.max_by(fn {_day, {count, _id}} -> count end)

    id * day
  end
end
