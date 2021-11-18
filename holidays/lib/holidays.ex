defmodule Holidays do
  @moduledoc """
  Documentation for `Holidays`.
  """
  @typedoc """

  """
  import Ecto.Query, only: [from: 2]
  @type time_unit() :: :day | :hour | :minute | :second


  @doc """
  Set database.

  """
  @spec init_db :: :ok
  def init_db() do
    file = File.read!("db\\us-california-nonworkingdays.ics")
    text_data = ICalendar.from_ics(file)

    Enum.each(text_data, fn x ->
      date = Date.from_erl!({2021, x.dtstart.month, x.dtstart.day})
      name = x.summary

      %Holidays.Day{}
      |> Holidays.Day.changeset(%{name: name, h_date: date})
      |> Holidays.Repo.insert()
    end)
  end

  @doc """
  Returns true if today is a holiday, and false it it's not.

  ## Parameters
    - day: Date to compare.

  ## Examples

      iex> Holidays.is_holiday()
      false

      iex> Holidays.is_holiday(~D[2021-12-25])
      true

  """
  @spec is_holiday(Calendar.date()) :: boolean()
  def is_holiday(day \\ Date.utc_today()) do
    query = from(d in Holidays.Day, where: d.h_date == ^day)
    Holidays.Repo.exists?(query)
  end

  defp unit_weight(:seconds), do: 1
  defp unit_weight(:minute), do: 60
  defp unit_weight(:hour), do: 3600
  defp unit_weight(:day), do: 3600 * 24

  @doc """
  Returns a float representing a number of `unit`s till closest holiday in the future.

  ## Parameters
    - now: DateTime to compare.
    - unit: System.time_unit(): `:day`, `:hour`, `:minute` or `:second`.

  ## Examples

      iex> Holidays.time_until_holiday(:seconds)
      325789

      iex> Holidays.time_until_holiday(~U[2021-12-25 00:00:00.000Z], :seconds)
      0

  """
  @spec time_until_holiday(Calendar.datetime(), time_unit()) :: integer()
  def time_until_holiday(now \\ DateTime.utc_now(), unit) do
    date_now = DateTime.to_date(now)

    if is_holiday(date_now) do
      0
    else
      query =
        from(
          d in Holidays.Day,
          where: d.h_date > ^date_now,
          select: min(d.h_date)
        )

      date = Holidays.Repo.one(query)
      date = DateTime.new!(date, ~T[00:00:00.000], "Etc/UTC")

      unit_weight = unit_weight(unit)
      DateTime.diff(date, now) / unit_weight
    end
  end
end
