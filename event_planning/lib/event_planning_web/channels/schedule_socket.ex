defmodule EventPlanningWeb.ScheduleSocket do
  use Phoenix.Socket

  channel "changes:lobby", EventPlanningWeb.ChangesChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
