import Config

config :massively_multiplayer_tic_tac_toe, MassivelyMultiplayerTttWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443]
