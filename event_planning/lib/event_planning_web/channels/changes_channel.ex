defmodule EventPlanningWeb.ChangesChannel do
  use Phoenix.Channel
  import Phoenix.HTML
  import Phoenix.HTML.Link
  alias EventPlanning.Repo
  alias EventPlanning.Event

  intercept(["add", "update", "delete"])

  def join("changes:lobby", _params, socket) do
    {:ok, socket}
  end

  def handle_in("add", %{"body" => body}, socket) do
    require IEx; IEx.pry
    %{
      "date" => date,
      "repetition" => repetition,
    } = body
    event = %{date: date, repetition: repetition}
    changeset = Event.changeset(%Event{}, event)
    {:ok, event} = Repo.insert(changeset)

    broadcast(socket, "add", %{id: event.id})
    {:noreply, socket}
  end

  # def handle_in("update", %{"body" => body}, socket) do
  # end

  # def handle_in("delete", %{"body" => body}, socket) do
  # end


  def handle_out("add", msg, socket) do
    require IEx; IEx.pry
    push(
      socket,
      "add",
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
end
