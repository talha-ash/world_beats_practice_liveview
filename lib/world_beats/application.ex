defmodule WorldBeats.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WorldBeatsWeb.Telemetry,
      WorldBeats.Repo,
      {DNSCluster, query: Application.get_env(:world_beats, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WorldBeats.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WorldBeats.Finch},
      # Start a worker by calling: WorldBeats.Worker.start_link(arg)
      # {WorldBeats.Worker, arg},
      # Start to serve requests, typically the last entry
      WorldBeatsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WorldBeats.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WorldBeatsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
