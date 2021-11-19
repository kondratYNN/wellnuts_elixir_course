defmodule EventPlanningWeb.AccountController do
  use EventPlanningWeb, :controller

  def index(conn, %{"fpasscode" => passcode}) do
    if passcode == "12345" do
      conn = put_session(conn, :message, "hmmm")
      redirect(conn, to: "/account/inner")
    else
      render(conn, "index.html")
    end
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, _params) do
    if get_session(conn, :message) == "hmmm" do
      render(conn, "show.html")
    else
      conn
      |> put_status(500)
    end
  end
end
