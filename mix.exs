defmodule Demo.MixProject do
  use Mix.Project

  def project do
    [
      app: :demo,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      consolidate_protocols: Mix.env() != :dev,
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Demo.Application, []},
      extra_applications:
        (Mix.env() == :prod &&
           [:logger, :runtime_tools, :os_mon]) ||
          [:logger, :runtime_tools, :os_mon, :debugger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  #
  # Version specifiers: https://hexdocs.pm/elixir/1.16.3/Version.html#module-requirements
  #
  #     ~>           | Translation
  #     ~> 2.0.0     | >= 2.0.0 and < 2.1.0
  #     ~> 2.1.2     | >= 2.1.2 and < 2.2.0
  #     ~> 2.1.3-dev | >= 2.1.3-dev and < 2.2.0
  #     ~> 2.0       | >= 2.0.0 and < 3.0.0
  #     ~> 2.1       | >= 2.1.0 and < 3.0.0
  defp deps do
    [
      # Ash
      {:ash, "~> 3.0"},
      {:ash_postgres, "~> 2.0"},
      {:ash_phoenix, ">= 2.1.0"},
      {:ash_authentication, ">= 4.6.4"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:bcrypt_elixir, "~> 3.0"},
      {:ash_graphql, "~> 1.0"},
      {:ash_paper_trail, ">= 0.3.0"},
      {:ash_archival, ">= 1.0.4"},
      {:ash_state_machine, ">= 0.2.7"},

      # Does not seem to run reliably on my darwin-aarch64 system, using replacement.
      # {:picosat_elixir, "~> 0.2"},
      {:simple_sat, "~> 0.1"},

      # Phoenix/LiveView
      {:phoenix, "~> 1.8.0-rc.3", override: true},
      {:phoenix_ecto, "~> 4.5"},
      {:absinthe_phoenix, "~> 2.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.9"},
      # version with debug output
      # {:phoenix_pubsub, path: "../phoenix_pubsub", override: true},
      {:phoenix_live_dashboard, "~> 0.8"},

      # Temporary
      {:heroicons,
       github: "tailwindlabs/heroicons", tag: "v2.1.1", sparse: "optimized", app: false, compile: false, depth: 1},

      # DB performance insights for dashboard
      {:ecto_psql_extras, "~> 0.8.3"},
      {:swoosh, "~> 1.5"},
      {:gen_smtp, "~> 1.1"},
      # Email templates
      {:mjml_eex, "~> 0.12"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      # {:plug_cowboy, "~> 2.5"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},

      # code generator & updater
      {:igniter, "~> 0.6", only: [:dev, :test]},
      # static code analysers
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      # test coverage export to lcov file
      {:lcov_ex, "~> 0.3", only: [:dev, :test], runtime: false},
      # HTML parser
      {:floki, ">= 0.30.0", only: :test},
      # documentation generator
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      # LLM usage rules
      {:usage_rules, "~> 0.1", only: :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # To affect the test database, run:
  #
  #     $ MIX_ENV=test mix db.reset
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "db.setup", "assets.setup", "assets.build"],
      "db.setup": ["ash_postgres.create", "ash_postgres.migrate", "run priv/repo/seeds.exs"],
      "db.reset": ["ash_postgres.drop", "db.setup"],
      # "s3.reset": ["cmd mc rb --force --dangerous local/demo-members-dev local/demo-cms-dev"],
      "assets.setup": ["cmd bun --cwd=assets install"],
      "assets.build": ["cmd bun --cwd=assets run vite build --mode=dev"],
      "assets.deploy": [
        "cmd bun --cwd=assets run vite build --mode=prod",
        "phx.digest"
      ],
      "assets.lint": ["cmd bun --cwd=assets run eslint ."],
      "assets.lint.fix": ["cmd bun --cwd=assets run eslint . --fix"],
      "assets.format": ["cmd bun --cwd=assets run prettier --write ."],
      "assets.format.check": ["cmd bun --cwd=assets run prettier --check ."],
      # "gettext.update_countries": ["run scripts/generate_countries_pot.exs"],
      "gettext.show_missing": ["run scripts/show_missing_translations.exs"],
      ci: [
        "format --check-formatted",
        "assets.format.check",
        "deps.unlock --check-unused",
        # "doctor --full --raise",
        "credo",
        "sobelow --config",
        "dialyzer",

        # Order might be important,
        # see https://elixirforum.com/t/cant-run-hex-mix-tasks-in-alias/65649/13
        fn _ -> Mix.ensure_application!(:hex) end,
        "hex.audit"
      ],
      # Some deps with NIFs seem to store artifacts in `deps`, so let's wipe it all!
      fullclean: ["cmd rm -rf deps _build .elixir_ls"],
      docs: ["ash.generate_resource_diagrams --format md", "docs"]
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "readme",
      extras: [
        "README.md"
      ],
      formatters: ["html"],
      before_closing_head_tag: &before_closing_head_tag/1
    ]
  end

  defp before_closing_head_tag(:html) do
    """
    <script>
    function mermaidLoaded() {
      mermaid.initialize({
        startOnLoad: false,
        theme: document.body.className.includes("dark") ? "dark" : "default"
      });
      let id = 0;
      for (const codeEl of document.querySelectorAll("pre code.mermaid")) {
        const preEl = codeEl.parentElement;
        const graphDefinition = codeEl.textContent;
        const graphEl = document.createElement("div");
        const graphId = "mermaid-graph-" + id++;
        mermaid.render(graphId, graphDefinition).then(({svg, bindFunctions}) => {
          graphEl.innerHTML = svg;
          bindFunctions?.(graphEl);
          preEl.insertAdjacentElement("afterend", graphEl);
          preEl.remove();
        });
      }
    }
    </script>
    <script async src="https://cdn.jsdelivr.net/npm/mermaid@10.2.3/dist/mermaid.min.js" onload="mermaidLoaded();"></script>
    """
  end
end
