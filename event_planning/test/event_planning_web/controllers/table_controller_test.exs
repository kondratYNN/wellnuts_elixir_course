defmodule EventPlanningWeb.TableControllerTest do
  use EventPlanningWeb.ConnCase

  @valid_attrs %{date: ~U[2022-01-01 13:30:00Z], repetition: "day"}
  @svalid_attrs %{date: ~U[2022-05-01 13:40:00Z], repetition: "month"}

  def fixture(:event) do
    {:ok, event} =
      %EventPlanning.Event{}
      |> EventPlanning.Event.changeset(@valid_attrs)
      |> EventPlanning.Repo.insert()

    event
  end

  defp create_event(_) do
    event = fixture(:event)
    %{event: event}
  end

  describe "my schedule" do
    test "show page", %{conn: conn} do
      conn = post(conn, Routes.table_path(conn, :my_schedule))
      assert html_response(conn, 200) =~ "Events"
    end
  end

  describe "create event" do
    test "show page", %{conn: conn} do
      conn = get(conn, Routes.table_path(conn, :new))
      assert html_response(conn, 200) =~ "New Event"
    end

    test "redirection to schedule", %{conn: conn} do
      conn = post(conn, Routes.table_path(conn, :create), event: @valid_attrs)
      assert redirected_to(conn) == Routes.table_path(conn, :my_schedule)
    end
  end

  describe "edit event" do
    setup [:create_event]

    test "show page", %{conn: conn, event: event} do
      conn = get(conn, Routes.table_path(conn, :edit, event))
      assert html_response(conn, 200) =~ "Edit Event"
    end

    test "redirection to schedule", %{conn: conn, event: event} do
      conn = put(conn, Routes.table_path(conn, :update, event), event: @svalid_attrs)
      assert redirected_to(conn) == Routes.table_path(conn, :my_schedule)
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes event", %{conn: conn, event: event} do
      conn = delete(conn, Routes.table_path(conn, :delete, event))
      assert redirected_to(conn) == Routes.table_path(conn, :my_schedule)
    end
  end
end
