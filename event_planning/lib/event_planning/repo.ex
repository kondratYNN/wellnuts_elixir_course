defmodule EventPlanning.Repo do
  use Ecto.Repo,
    otp_app: :event_planning,
    adapter: Ecto.Adapters.Postgres
end
