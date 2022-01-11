defmodule Mix.Tasks.InitDb do
  @moduledoc false
  use Mix.Task

  @shortdoc "function init_db/0 with to set databas."
  def run(_) do
    Mix.Task.run("app.start")

    file = File.read!("db\\us-california-nonworkingdays.ics")
    text_data = ICalendar.from_ics(file)

    Enum.reduce(text_data, Holidays.Repo, fn x, acc ->
      date = Date.from_erl!({2021, x.dtstart.month, x.dtstart.day})
      name = x.summary
      holiday = %Holidays.Day{name: name, h_date: date}
      # хоть day мне не нужен, но иначе просто не работает
      {:ok, day} = acc.insert(holiday)
      acc
    end)
  end
end
