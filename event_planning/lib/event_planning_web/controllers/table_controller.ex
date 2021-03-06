defmodule EventPlanningWeb.TableController do
  use EventPlanningWeb, :controller
  import Ecto.Query, only: [from: 2]
  import Ecto

  alias Ecto.Multi
  alias EventPlanning.Repo
  alias EventPlanning.Event
  alias EventPlanning.User

  plug(:assign_user)

  @day_sec 86400
  @week_sec 604_800
  @year_sec 31_536_000

  defp assign_user(conn, _params) do
    %{"user_id" => user_id} = conn.params

    case Repo.get(User, user_id) do
      nil -> redirect(conn, to: Routes.account_path(conn, :index))
      user -> assign(conn, :user, user)
    end
  end

  def my_schedule(conn, %{"page" => %{"categories_id" => categories_id}}) do
    render_my_schedule(conn, categories_id)
  end

  def my_schedule(conn, %{"file" => file}) do
    render_my_schedule(conn, "week", file.path)
  end

  def my_schedule(conn, _params) do
    render_my_schedule(conn, "week")
  end

  def filter_events(events) do
    events
    |> Enum.reject(fn x -> x.repetition == "none" and x.date > DateTime.now!("Etc/UTC") end)
    |> Enum.map(fn x ->
      %{
        x
        | date:
            DateTime.to_naive(
              place_to_future(
                DateTime.from_naive!(x.date, "Etc/UTC"),
                DateTime.now!("Etc/UTC"),
                x.repetition
              )
            )
      }
    end)
  end

  def render_my_schedule(conn, categories_id, filepath) do
    categories = ["week", "month", "year"]
    file = ICalendar.from_ics(File.read!(filepath))

    Enum.reduce(file, Multi.new(), fn x, acc ->
      event = %{
        "name" => x.summary,
        "date" => x.dtstart,
        "repetition" => x.description
      }

      changeset = Event.changeset(%Event{}, event)

      Ecto.Multi.insert(acc, {:insert, x.summary}, changeset)
    end)
    |> Repo.transaction()

    event = filter_events(Repo.all(assoc(conn.assigns[:user], :event)))
    event = date_boundaries(event, categories_id)

    nonc_events = nonconflicting_events(event)
    c_events = conflicting_events(event)

    render(conn, "my_schedule.html",
      events: event,
      conflicting_events: c_events,
      nonconflicting_events: nonc_events,
      categories: categories
    )
  end

  def render_my_schedule(conn, categories_id) do
    categories = ["week", "month", "year"]

    event = filter_events(Repo.all(assoc(conn.assigns[:user], :event)))
    event = date_boundaries(event, categories_id)

    nonc_events = nonconflicting_events(event)
    c_events = conflicting_events(event)

    render(conn, "my_schedule.html",
      events: event,
      conflicting_events: c_events,
      nonconflicting_events: nonc_events,
      categories: categories
    )
  end

  defp date_boundaries(events, "week") do
    Enum.reject(events, fn x ->
      DateTime.diff(
        DateTime.from_naive!(x.date, "Etc/UTC"),
        DateTime.add(DateTime.now!("Etc/UTC"), @week_sec)
      ) > 0
    end)
  end

  defp date_boundaries(events, "month") do
    date_now = DateTime.now!("Etc/UTC")

    date_end =
      DateTime.add(
        date_now,
        @day_sec *
          Calendar.ISO.days_in_month(
            DateTime.to_date(date_now).year,
            DateTime.to_date(date_now).month
          )
      )

    Enum.reject(events, fn x ->
      DateTime.diff(DateTime.from_naive!(x.date, "Etc/UTC"), date_end) > 0
    end)
  end

  defp date_boundaries(events, "year") do
    Enum.reject(events, fn x ->
      DateTime.diff(
        DateTime.from_naive!(x.date, "Etc/UTC"),
        DateTime.add(DateTime.now!("Etc/UTC"), @year_sec)
      ) > 0
    end)
  end

  defp count_conflicting_events(events, event) do
    Enum.reduce(events, -1, fn x, ac ->
      if event.date == x.date do
        ac + 1
      else
        ac
      end
    end)
  end

  defp nonconflicting_events(events) do
    Enum.reduce(events, [], fn x, acc ->
      if count_conflicting_events(events, x) == 0 do
        List.insert_at(acc, -1, x)
      else
        acc
      end
    end)
  end

  defp conflicting_events(events) do
    Enum.reduce(events, [], fn x, acc ->
      if count_conflicting_events(events, x) != 0 do
        List.insert_at(acc, -1, x)
      else
        acc
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    event = Repo.get(Event, id)

    if Ability.can?(event, :read, conn.assigns[:user]) do
      render(conn, "show.html", event: event)
    else
      redirect(conn, to: Routes.account_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    event = Repo.get(Event, id)

    if Ability.can?(event, :update, conn.assigns[:user]) do
      changeset = Event.changeset(event, %{})
      render(conn, "edit.html", event: event, changeset: changeset)
    else
      redirect(conn, to: Routes.account_path(conn, :index))
    end
  end

  def update_event(%Event{} = event, att) do
    event
    |> Event.changeset(att)
    |> Repo.update()
  end

  def update(conn, _params) do
    redirect(conn, to: Routes.user_table_path(conn, :my_schedule, conn.assigns[:user]))
  end

  def delete(conn, %{"id" => id}) do
    event = Repo.get(Event, id)
    redirect(conn, to: Routes.user_table_path(conn, :my_schedule, conn.assigns[:user]))
  end

  def create(conn, _params) do
    redirect(conn, to: Routes.user_table_path(conn, :my_schedule, conn.assigns[:user]))
  end

  def new(conn, params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:event)
      |> Event.changeset(params)

    render(conn, "new.html", changeset: changeset)
  end

  def place_to_future(date, now, "year") do
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, @year_sec)
      place_to_future(date, now, "year")
    end
  end

  def place_to_future(date, now, "month") do
    if DateTime.diff(date, now) > 0 do
      date
    else
      date =
        DateTime.add(
          date,
          @day_sec *
            Calendar.ISO.days_in_month(DateTime.to_date(date).year, DateTime.to_date(date).month)
        )

      place_to_future(date, now, "month")
    end
  end

  def place_to_future(date, now, "week") do
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, @week_sec)
      place_to_future(date, now, "week")
    end
  end

  def place_to_future(date, now, "day") do
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, @day_sec)
      place_to_future(date, now, "day")
    end
  end

  def place_to_future(date, _now, "none") do
    date
  end

  def next_event(conn, _params) do
    events = filter_events(Repo.all(assoc(conn.assigns[:user], :event)))

    if events == [] do
      render(conn, "next_event.html",
        event: [],
        time: 0
      )
    else
      closest_event =
        Enum.min_by(
          events,
          &DateTime.diff(
            DateTime.from_naive!(&1.date, "Etc/UTC"),
            DateTime.now!("Etc/UTC")
          )
        )

      render(conn, "next_event.html",
        event: closest_event,
        time:
          DateTime.diff(
            DateTime.from_naive!(closest_event.date, "Etc/UTC"),
            DateTime.now!("Etc/UTC")
          )
      )
    end
  end
end
