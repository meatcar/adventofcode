defmodule Mix.Tasks.Day do
  @moduledoc """
  Mix task to get the solution for a given day. Fetches the puzzle
  input off adventofcode.com, with the configured cookie.
  """

  use Mix.Task

  require HTTPoison

  def fetchInput(year, day) do
    HTTPoison.start()

    response =
      HTTPoison.get("https://adventofcode.com/#{year}/day/#{day}/input", [
        {"Cookie", Application.fetch_env!(:advent, :ADVENTOFCODE_COOKIE)}
      ])

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, String.trim(body)}

      x ->
        {:fail, x}
    end
  end

  @doc """
  Get the puzzle input for a given day and year. Cache it as a file in ./input

  ### Example

      iex> Mix.Tasks.Day.getInput(2017, 3)
      {:ok, "325489"}

  """
  def getInput(year, day) do
    dir = "./input"
    file = "#{dir}/#{year}-#{day}"
    if not File.dir?(dir), do: :ok = File.mkdir(dir)

    if not File.exists?(file) do
      with {:ok, input} <- fetchInput(year, day) do
        :ok = File.write(file, input)
      end
    end

    File.read(file)
  end

  def run([day]) do
    {:ok, input} = getInput(2018, day)

    # TODO: hotload modules.
    days = {
      Day01,
      Day02,
      Day03,
      Day04,
      Day05
    }

    module = elem(days, String.to_integer(day) - 1)

    IO.puts("2018/#{day}, part 1:")
    IO.puts(module.part1(input))
    IO.puts("2018/#{day}, part 2:")
    IO.puts(module.part2(input))
  end
end
