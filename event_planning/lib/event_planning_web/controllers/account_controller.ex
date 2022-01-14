defmodule EventPlanningWeb.AccountController do
  use EventPlanningWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias EventPlanning.User
  alias EventPlanning.Repo

  @session_msg "QWerTY123"
  @password "12345"

  def index(conn, _params) do
    # changeset = User.changeset(%User{}, %{
    #   email: "user@user.com",
    #   role: "user"
    # })
    # Repo.insert(changeset)
    render(conn, "index.html")
  end

  defp check_login(email, password) do
    if password == @password do
      query = from(u in User, where: u.email == ^email)

      case Repo.one(query) do
        %User{} = user -> {:ok, user}
        nil -> {:error, :unauthorized}
      end
    else
      {:error, :unauthorized}
    end
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case check_login(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, %{id: user.id})
        |> put_session(:message, @session_msg)
        |> redirect(to: Routes.user_table_path(conn, :my_schedule, user.id))

      {:error, :unauthorized} ->
        redirect(conn, to: Routes.account_path(conn, :index))
    end
  end
end
