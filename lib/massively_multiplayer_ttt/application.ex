defmodule MassivelyMultiplayerTtt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MassivelyMultiplayerTttWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MassivelyMultiplayerTtt.PubSub},
      # Start the Endpoint (http/https)
      MassivelyMultiplayerTttWeb.Endpoint,
      # Start a worker by calling: MassivelyMultiplayerTtt.Worker.start_link(arg)
      # {MassivelyMultiplayerTtt.Worker, arg}

      MassivelyMultiplayerTtt.GameServer,
      MassivelyMultiplayerTtt.UsernameServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MassivelyMultiplayerTtt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MassivelyMultiplayerTttWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
