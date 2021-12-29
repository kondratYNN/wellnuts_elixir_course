defmodule EventPlanningWeb.ChangesChannel do
  use Phoenix.Channel
  import Phoenix.HTML
  import Phoenix.HTML.Link
  alias EventPlanning.Repo
  alias EventPlanning.Event

  intercept(["create"])

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
    # require IEx; IEx.pry
    # %{
    #   "date" => date,
    #   "repetition" => repetition,
    # } = body
    # event = %{date: date, repetition: repetition}
    # changeset = Event.changeset(%Event{}, event)
    # {:ok, event} = Repo.insert(changeset)
    event =
      %Event{}
      |> Event.changeset(%{date: parse_date(data), repetition: data["repetition"]})
      |> Repo.insert!()

    broadcast(socket, "create", %{id: event.id})
    {:noreply, socket}
  end

  # def handle_in("update", %{"body" => body}, socket) do
  # end

  # def handle_in("delete", %{"body" => body}, socket) do
  # end

  @impl true
  def handle_out("create", msg, socket) do
    # require IEx; IEx.pry
    # push(
    #   socket,
    #   "add",
    #   Map.merge(
    #     msg,
    #     %{html_event: generate_html(Repo.get(Event, msg.id))}
    #   )
    # )
    require IEx; IEx.pry
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

  # def handle_out("update_e", msg, socket) do
  #   {:noreply, socket}
  # end

  # def handle_out("delete_e", msg, socket) do
  #   {:noreply, socket}
  # end

  def generate_html(event) do
    ~E"""
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
    # %DateTime{
    #   year: string_to_integer(year),
    #   month: string_to_integer(month),
    #   day: string_to_integer(day),
    #   hour: string_to_integer(hour),
    #   minute: string_to_integer(minute),
    #   zone_abbr: "UTC",
    #   second: 1,
    #   microsecond: {0, 0},
    #   utc_offset: 0,
    #   std_offset: 0,
    #   time_zone: "Etc/UTC"
    # }
  end

  # defp string_to_integer(string) do
  #   {integer, ""} = Integer.parse(string)
  #   integer
  # end
end
