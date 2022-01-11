defmodule EventPlanningWeb.ChangesChannel do
  use Phoenix.Channel
  import Phoenix.HTML
  import Phoenix.HTML.Link
  alias EventPlanning.Repo
  alias EventPlanning.Event

  intercept(["create", "update"])

  @impl true
  def join("changes:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end


  @impl true
  def handle_in("create", %{"data" => data}, socket) do
    event =
      %Event{}
      |> Event.changeset(%{name: data["name"], date: parse_date(data), repetition: data["repetition"]})
      |> Repo.insert!()

    broadcast(socket, "create", %{id: event.id})
    {:noreply, socket}
  end

  @impl true
  def handle_in("update", %{"data" => data}, socket) do
    event = Repo.get(Event, data["id"])
    |> Event.changeset(%{name: data["name"], date: parse_date(data), repetition: data["repetition"]})
    |> Repo.update!()

    broadcast(socket, "update", %{id: event.id})
    {:noreply, socket}
  end

  def handle_in("delete", %{"data" => id}, socket) do
    broadcast(socket, "delete", %{id: id})
    {:noreply, socket}
  end

  @impl true
  def handle_out("create", msg, socket) do
    push(
      socket,
      "create",
      Map.merge(
        msg,
        %{html_event: generate_html(Repo.get(Event, msg.id))}
      )
    )

    {:noreply, socket}
  end

  @impl true
  def handle_out("update", msg, socket) do
    push(
      socket,
      "update",
      Map.merge(
        msg,
        %{html_event: generate_html(Repo.get(Event, msg.id))}
      )
    )

    {:noreply, socket}
  end

  @impl true
  def handle_out("delete", msg, socket) do
    push(
      socket,
      "delete",
      msg
    )

    {:noreply, socket}
  end

  def generate_html(event) do
    ~E"""
    <td><%= event.name %></td>
    <td><%= event.date %></td>
    <td><%= event.repetition %></td>
    <td>
      <span><%= link "Show", to: "event/" <> Integer.to_string(event.id) %></span>
    </td>
    """
    |> safe_to_string()
  end

  defp parse_date(%{"date_year" => year, "date_month" => month, "date_day" => day, "date_hour" => hour, "date_minute" => minute}) do
    DateTime.new!(
      Date.new!(
        String.to_integer(year),
        String.to_integer(month),
        String.to_integer(day)
      ),
      Time.new!(String.to_integer(hour), String.to_integer(minute), 0, 0)
    )
  end

end
