defmodule EventPlanningWeb.EventChannel do
  use EventPlanningWeb, :channel
  alias EventPlanning.{Event, Repo}

  intercept(["create_event"])

  @impl true
  def join("room:lobby", _payload, socket) do
    # if authorized?(payload) do
    send(self(), :after_join)
    {:ok, socket}
    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("create_event", %{"data" => data}, socket) do
    event =
      %Event{}
      |> Event.changeset(%{date: parse_date(data), repetition: data["repetition"]})
      |> Repo.insert!()

    broadcast(socket, "create_event", %{event_id: event.id})
    {:noreply, socket}
  end

  @impl true
  def handle_out("create_event", %{event_id: event_id}, socket) do
    event = Repo.get(Event, event_id)
    push(socket, "create_event", %{html_template: generate_html(event)})

    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:noreply, socket}
  end

  defp generate_html(_event) do
    "Hello World!"
  end

  defp parse_date(%{"date_year" => year, "date_month" => month, "date_day" => day, "date_hour" => hour, "date_minute" => minute}) do
    %DateTime{
      year: string_to_integer(year),
      month: string_to_integer(month),
      day: string_to_integer(day),
      hour: string_to_integer(hour),
      minute: string_to_integer(minute),
      zone_abbr: "UTC",
      second: 1,
      microsecond: {0, 0},
      utc_offset: 0,
      std_offset: 0,
      time_zone: "Etc/UTC"
    }
  end

  defp string_to_integer(string) do
    {integer, ""} = Integer.parse(string)
    integer
  end
end
