defmodule Holiday do
  @moduledoc """
  Documentation for `Holiday`.
  """
  @typedoc """

  """
  @type time_unit() :: :day | :hour | :minute | :second
  @doc """
  Returns holiday database as list of %ICalendar.Event objects.

  ## Parameters

    No parameters.

  ## Examples

      iex> Holiday.init_db()
      [
        %ICalendar.Event{
        attendees: [],
        categories: nil,
        class: "public",
        comment: nil,
        description: nil,
        dtend: ~U[1970-12-26 00:00:00Z],
        dtstart: ~U[1970-12-25 00:00:00Z],
        exdates: [],
        geo: nil,
        location: nil,
        modified: ~U[2020-04-25 15:38:22Z],
        organizer: nil,
        prodid: nil,
        rrule: %{freq: "YEARLY"},
        sequence: "0",
        status: "confirmed",
        summary: "Christmas",
        uid: "c1679873-ff26-4f96-a628-01e89a2049fb",
        url: nil
        }
      ]

  """
  @spec init_db() :: list()
  def init_db() do
    file = File.read!("db\\us-california-nonworkingdays.ics")
    ICalendar.from_ics(file)
  end

  @doc """
  Returns true if today is a holiday, and false it it's not.

  ## Parameters

    - db:  result of calling `init_db()`.
    - day: Date to compare.

  ## Examples

      iex> Holiday.is_holiday(db)
      false

      iex> Holiday.is_holiday(db,~D[2020-12-25])
      true

  """
  @spec is_holiday(list(), Calendar.date()) :: boolean()
  def is_holiday(db, day \\ Date.utc_today()) do
    Enum.any?(db, fn x -> day.month == x.dtstart.month and day.day == x.dtstart.day end)
  end

  @doc """
  Returns a float representing a number of `unit`s till closest holiday in the future.

  ## Parameters

    - db:  result of calling `init_db()`.
    - now: DateTime to compare.
    - unit: System.time_unit(): `:day`, `:hour`, `:minute` or `:second`.

  ## Examples

      iex> Holiday.is_holiday(db)
      false

      iex> Holiday.is_holiday(db,~D[2020-12-25])
      true

  """
  @spec time_until_holiday(list(), Calendar.datetime(), time_unit()) :: integer()
  def time_until_holiday(db, now \\ DateTime.utc_now(), unit) do
    if is_holiday(db, DateTime.to_date(now)) == true do
      0
    else
      db_ch =
        Enum.map(db, fn x ->
          if x.dtstart.month < now.month or
               (x.dtstart.month == now.month and x.dtstart.day < now.day) do
            DateTime.add(x.dtstart, 1_640_995_200)
          else
            DateTime.add(x.dtstart, 1_609_459_200)
          end
        end)

      unit_weight =
        case unit do
          :seconds -> 1
          :minute -> 60
          :hour -> 3600
          :day -> 3600 * 24
        end

      timings = for date <- db_ch, do: DateTime.diff(date, now) / unit_weight
      timings = Enum.filter(timings, fn x -> x > 0 end)
      Enum.min(timings)
    end
  end
end

db = Holiday.init_db()
IO.puts(Holiday.is_holiday(db, ~D[2020-12-25]))
IO.puts(Holiday.is_holiday(db))
IO.puts(Holiday.time_until_holiday(db, :day))
IO.puts(Holiday.time_until_holiday(Holiday.init_db(), ~U[2021-12-24 01:00:00Z], :hour))
