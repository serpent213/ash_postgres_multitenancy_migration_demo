# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :demo,
  ecto_repos: [Demo.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [Demo.TimeTracking, Demo.Accounts]

config :ash_graphql, authorize_update_destroy_with_error?: true

config :ash,
  allow_forbidden_field_for_relationships_by_default?: true,
  include_embedded_source_by_default?: false,
  show_keysets_for_all_actions?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false],
  keep_read_action_loads_when_loading?: false,
  default_actions_require_atomic?: true,
  read_action_after_action_hooks_in_order?: true,
  bulk_actions_default_to_errors?: true

# config :ash, :tracer, Demo.DebugTracer

# Configures the endpoint
config :demo, DemoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DemoWeb.ErrorHTML, json: DemoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Demo.PubSub,
  live_view: [signing_salt: "4t/7b6zB"]

# Oban scheduler
# config :heimdall, Oban,
#   engine: Oban.Engines.Basic,
#   queues: [default: 10],
#   repo: Demo.Repo,
#   plugins: [
#     {Oban.Plugins.Pruner, max_age: 31 * 24 * 60 * 60},
#     {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(15)},
#     {Oban.Plugins.Cron,
#      crontab: [
#        # Minute Hour Day Month DayOfWeek
#        # {"*/30 * * * *", HeimdallWeb.Jobs.PruneSessionStore},
#        # Download using USNO API
#        # {"11 0 1 */6 *", Heimdall.Jobs.ImportMoonPhases, args: %{future_years: 5}}
#        # {"0 12 * * MON", MyApp.MondayWorker, queue: :scheduled, tags: ["mondays"]},
#        # {"@daily", MyApp.AnotherDailyWorker}
#      ]},
#     {Oban.Plugins.Reindexer, schedule: "@weekly"}
#   ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :demo, Demo.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :resource,
        :code_interface,
        :actions,
        :policies,
        :attributes,
        :state_machine,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :relationships,
        :multitenancy,
        :calculations,
        :aggregates,
        :identities,
        :authentication,
        :archive,
        :paper_trail,
        :admin,
        :graphql,
        :postgres
      ]
    ],
    "Ash.Domain": [
      section_order: [
        :resources,
        :graphql,
        :policies,
        :authorization,
        :domain,
        :execution,
        :paper_trail,
        :admin
      ]
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
