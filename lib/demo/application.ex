defmodule Demo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DemoWeb.Telemetry,
      Demo.Repo,
      {DNSCluster, query: Application.get_env(:demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Demo.PubSub},
      # Start a worker by calling: Demo.Worker.start_link(arg)
      # {Demo.Worker, arg},
      # Start to serve requests, typically the last entry
      {AshAuthentication.Supervisor, [otp_app: :demo]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
