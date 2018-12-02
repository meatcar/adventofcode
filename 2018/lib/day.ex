defmodule Mix.Tasks.Day do
  use Mix.Task

  require HTTPoison

  @doc """
  Fetch the puzzle input for a given day and year.

  ### Example

      iex> Mix.Tasks.Day.fetchInput(2017, 3)
      {:ok, "325489"}

  """
  def fetchInput(year, day) do
    HTTPoison.start()

    response = HTTPoison.get("https://adventofcode.com/#{year}/day/#{day}/input", [
      {"Cookie", Application.fetch_env!(:advent, :ADVENTOFCODE_COOKIE)}
    ])

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
	{:ok, String.trim(body)}
      x ->
	IO.inspect x
	{:fail, x}
    end

  end

  def run([day]) do
    {:ok, input} = fetchInput(2018, day)

    # TODO: hotload modules.
    days = {
      Day01,
      Day02
    }
    module = elem(days, String.to_integer(day) - 1)

    IO.puts("2018/#{day}, part 1:")
    IO.puts(module.part1(input))
    IO.puts("2018/#{day}, part 2:")
    IO.puts(module.part2(input))
  end
end
