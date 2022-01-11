defmodule Mix.Tasks.IsHoliday do
  @moduledoc false
  use Mix.Task

  @shortdoc "function is_holiday/0 with today date."
  def run(_) do
    Mix.Task.run("app.start")

    if Holidays.is_holiday() do
      IO.puts("yes")
    else
      IO.puts("no")
    end
  end
end
