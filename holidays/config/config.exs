import Config

config :holidays, Holidays.Repo,
  database: "holidays_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

  config :holidays, ecto_repos: [Holidays.Repo]
