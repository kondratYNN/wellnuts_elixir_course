import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :event_planning, EventPlanning.Repo,
  username: "postgres",
  password: "postgres",
  database: "event_planning_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :event_planning, EventPlanningWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "fSYLTg2H4W6x26WmImIYA4+z0Ty+swCkjNSCVuAsTpm4bHWS6AvCCaTq8ZAyKFpw",
  server: false

# In test we don't send emails.
config :event_planning, EventPlanning.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
