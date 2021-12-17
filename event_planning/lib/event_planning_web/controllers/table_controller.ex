defmodule EventPlanningWeb.TableController do
  use EventPlanningWeb, :controller
  import Ecto.Query, only: [from: 2]

  def my_schedule(conn, params) when params == %{} do
    render_my_schedule(conn, "week")
  end

  def my_schedule(conn, params) when params !== %{} do
    %{"page" => %{"categories_id" => categories_id}} = conn.body_params
    render_my_schedule(conn, categories_id)
  end

  def render_my_schedule(conn, categories_id) do
    categories = ["week", "month", "year"]

    q = Ecto.Query.from(e in EventPlanning.Event)
    event = EventPlanning.Repo.all(q)

    event =
      Enum.reject(event, fn x -> x.repetition == "none" and x.date < DateTime.now!("Etc/UTC") end)

    event =
      Enum.map(event, fn x ->
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

  defp date_boundaries(events, categories_id) when categories_id == "week" do
    Enum.reject(events, fn x ->
      DateTime.diff(
        DateTime.from_naive!(x.date, "Etc/UTC"),
        DateTime.add(DateTime.now!("Etc/UTC"), 604_800)
      ) > 0
    end)
  end

  defp date_boundaries(events, categories_id) when categories_id == "month" do
    date_now = DateTime.now!("Etc/UTC")

    date_end =
      DateTime.add(
        date_now,
        86400 *
          Calendar.ISO.days_in_month(
            DateTime.to_date(date_now).year,
            DateTime.to_date(date_now).month
          )
      )

    Enum.reject(events, fn x ->
      DateTime.diff(DateTime.from_naive!(x.date, "Etc/UTC"), date_end) > 0
    end)
  end

  defp date_boundaries(events, categories_id) when categories_id == "year" do
    Enum.reject(events, fn x ->
      DateTime.diff(
        DateTime.from_naive!(x.date, "Etc/UTC"),
        DateTime.add(DateTime.now!("Etc/UTC"), 31_536_000)
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
    event = EventPlanning.Repo.get(EventPlanning.Event, id)
    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = EventPlanning.Repo.get(EventPlanning.Event, id)
    changeset = EventPlanning.Event.changeset(event, %{})
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update_event(%EventPlanning.Event{} = event, att) do
    event
    |> EventPlanning.Event.changeset(att)
    |> EventPlanning.Repo.update()
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = EventPlanning.Repo.get(EventPlanning.Event, id)

    case update_event(event, event_params) do
      {:ok, _event} ->
        conn
        |> redirect(to: Routes.table_path(conn, :my_schedule))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = EventPlanning.Repo.get(EventPlanning.Event, id)

    if event do
      {:ok, _event} = EventPlanning.Repo.delete(event)
    end

    conn
    |> redirect(to: Routes.table_path(conn, :my_schedule))
  end

  def create(conn, %{"event" => event_params}) do
    %EventPlanning.Event{}
    |> EventPlanning.Event.changeset(event_params)
    |> EventPlanning.Repo.insert()

    conn
    |> redirect(to: Routes.table_path(conn, :my_schedule))
  end

  def new(conn, params) do
    changeset = EventPlanning.Event.changeset(%EventPlanning.Event{}, params)
    render(conn, "new.html", changeset: changeset)
  end

  def place_to_future(date, now, repetition) when repetition == "year" do
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, 31_536_000)
      place_to_future(date, now, repetition)
    end
  end

  def place_to_future(date, now, repetition) when repetition == "month" do
    if DateTime.diff(date, now) > 0 do
      date
    else
      date =
        DateTime.add(
          date,
          86400 *
            Calendar.ISO.days_in_month(DateTime.to_date(date).year, DateTime.to_date(date).month)
        )

      place_to_future(date, now, repetition)
    end
  end

  def place_to_future(date, now, repetition) when repetition == "week" do
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, 604_800)
      place_to_future(date, now, repetition)
    end
  end

  def place_to_future(date, now, repetition) when repetition == "day" do
    if DateTime.diff(date, now) > 0 do
      date
    else
      date = DateTime.add(date, 86400)
      place_to_future(date, now, repetition)
    end
  end

  def place_to_future(date, _now, repetition) when repetition == "none" do
    date
  end

  def next_event(conn, _params) do
    q = Ecto.Query.from(e in EventPlanning.Event)
    events = EventPlanning.Repo.all(q)

    events =
      Enum.reject(events, fn x -> x.repetition == "none" and x.date < DateTime.now!("Etc/UTC") end)

    events =
      Enum.map(events, fn x ->
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
