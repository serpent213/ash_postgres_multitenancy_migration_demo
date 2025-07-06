import Config

# Verbose debugging output?
debug = true

config :demo, token_signing_secret: "Fz+YqA4v3HciaNN80aqJUoKyvLD2Qikh"
config :bcrypt_elixir, log_rounds: 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :demo, Demo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "demo_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :demo, DemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/hwKNCj1MVLD0QBbJDYgmE4CKSLiCIjfEu9fk/8r5JUwD2RCZrUp77yXa8xVIJD9",
  server: false

# In test we don't send emails
config :demo, Demo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

if debug do
  config :logger, level: :debug
  config :ash_authentication, debug_authentication_failures?: true
else
  # Print only warnings and errors during test
  config :logger, level: :warning
end
