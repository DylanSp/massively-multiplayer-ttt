defmodule MassivelyMultiplayerTtt.Messaging do
  def subscribe_to_game do
    Phoenix.PubSub.subscribe(MassivelyMultiplayerTtt.PubSub, "game")
  end

  def broadcast_new_game() do
    Phoenix.PubSub.broadcast(MassivelyMultiplayerTtt.PubSub, "game", :new_game)
  end

  def broadcast_game_update(game) do
    Phoenix.PubSub.broadcast(MassivelyMultiplayerTtt.PubSub, "game", {:game_updated, game})
  end
end
