defmodule FetchInput do
  require HTTPoison

  @doc """
  Fetch the puzzle input for a given day and year.

  ### Example

      iex> FetchInput.run(2017, 3)
      {:ok, "325489"}

  """
  def run(year, day) do
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
end
