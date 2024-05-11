defmodule Alchemist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AlchemistWeb.Telemetry,
      Alchemist.Repo,
      {DNSCluster, query: Application.get_env(:alchemist, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Alchemist.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Alchemist.Finch},
      # Start a worker by calling: Alchemist.Worker.start_link(arg)
      # {Alchemist.Worker, arg},
      # Start to serve requests, typically the last entry
      AlchemistWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Alchemist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AlchemistWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
