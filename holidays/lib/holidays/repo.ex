defmodule Holidays.Repo do
  use Ecto.Repo,
    otp_app: :holidays,
    adapter: Ecto.Adapters.Postgres
end
