defmodule MassivelyMultiplayerTtt.Messaging do
  @pubsub MassivelyMultiplayerTtt.PubSub
  @game_topic "game"
  @names_topic "names"

  def subscribe_to_game() do
    Phoenix.PubSub.subscribe(@pubsub, @game_topic)
  end

  def subscribe_to_names() do
    Phoenix.PubSub.subscribe(@pubsub, @names_topic)
  end

  def broadcast_new_game() do
    Phoenix.PubSub.broadcast(@pubsub, @game_topic, :new_game)
  end

  def broadcast_game_update(game) do
    Phoenix.PubSub.broadcast(@pubsub, @game_topic, {:game_updated, game})
  end

  def broadcast_name_added(name) do
    Phoenix.PubSub.broadcast(@pubsub, @names_topic, {:new_name, name})
  end

  def broadcast_name_changed(old_name, new_name) do
    Phoenix.PubSub.broadcast(@pubsub, @names_topic, {:name_changed, old_name, new_name})
  end

  def broadcast_name_removed(name) do
    Phoenix.PubSub.broadcast(@pubsub, @names_topic, {:name_removed, name})
  end
end
