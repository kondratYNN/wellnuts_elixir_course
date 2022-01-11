defmodule JokeTask do
  def get_joke do
    HTTPoison.start()
    url = "https://nova-joke-api.netlify.app/.netlify/functions/index/random_joke"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        encoded = Jason.decode!(body)
        encoded["setup"] <> "  " <> encoded["punchline"]

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        "Not found :("

      {:error, %HTTPoison.Error{reason: reason}} ->
        reason
    end
  end

  def print_joke do
    HTTPoison.start()
    url = "https://nova-joke-api.netlify.app/.netlify/functions/index/random_joke"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        encoded = Jason.decode!(body)
        IO.puts(encoded["setup"])
        IO.puts(encoded["punchline"])

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end
end

IO.puts(JokeTask.get_joke())
JokeTask.print_joke()
