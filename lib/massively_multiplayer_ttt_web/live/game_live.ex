defmodule MassivelyMultiplayerTttWeb.GameLive do
  use MassivelyMultiplayerTttWeb, :live_view
  use Phoenix.HTML
  import MassivelyMultiplayerTtt.Game
  import MassivelyMultiplayerTtt.GameLiveMonitor
  import MassivelyMultiplayerTtt.Messaging
  import MassivelyMultiplayerTtt.UsernameServer

  def mount(_params, _session, socket) do
    socket = assign(socket, username: "Connecting...", all_names: [])

    if connected?(socket) do
      monitor(socket.id, self())
      subscribe_to_game()
      subscribe_to_names()
      username = get_new_username()
      socket = assign(socket, username: username)
      # TODO fix game resetting when new connection made; move to separate game server?
      {:ok, reset_game(socket)}
    else
      {:ok, reset_game(socket)}
    end
  end

  def handle_event("change_username", form_data, socket) do
    old_name = socket.assigns.username
    new_name = form_data["username"]["value"]

    case new_name do
      "" ->
        # TODO Flash error message
        {:noreply, socket}

      _ ->
        _ = change_username(old_name, new_name)
        socket = assign(socket, username: new_name)
        {:noreply, socket}
    end
  end

  def handle_event("new_game", _, socket) do
    socket = reset_game(socket)
    broadcast_new_game()
    {:noreply, socket}
  end

  def handle_event("click_cell", %{"cell-num" => cell_num}, socket) do
    cell_num = String.to_integer(cell_num)
    {move_result, new_game} = make_move(socket.assigns.game, cell_num)

    socket =
      case move_result do
        :game_already_over ->
          # TODO Replace with flash message
          IO.puts("game already over")
          socket

        :square_filled ->
          # TODO Replace with flash message
          IO.puts("square filled")
          socket

        _ ->
          assign(socket, game: new_game, status_message: get_status_message(new_game))
      end

    broadcast_game_update(new_game)

    {:noreply, socket}
  end

  def handle_info(:new_game, socket) do
    {:noreply, reset_game(socket)}
  end

  def handle_info({:game_updated, game}, socket) do
    socket = assign(socket, game: game, status_message: get_status_message(game))
    {:noreply, socket}
  end

  def handle_info({:new_name, name}, socket) do
    IO.puts("Name added: #{name}")
    socket = assign(socket, all_names: [name | socket.assigns.all_names])
    {:noreply, socket}
  end

  def handle_info({:name_changed, old_name, new_name}, socket) do
    IO.puts("Old name: #{old_name}")
    IO.puts("New name: #{new_name}")
    # TODO implement
    position = Enum.find_index(socket.assigns.all_names, fn name -> name == old_name end)

    socket =
      assign(socket, all_names: List.replace_at(socket.assigns.all_names, position, new_name))

    {:noreply, socket}
  end

  def handle_info({:name_removed, name}, socket) do
    IO.puts("Name removed: #{name}")
    socket = assign(socket, all_names: List.delete(socket.assigns.all_names, name))
    {:noreply, socket}
  end

  defp reset_game(socket) do
    game = %MassivelyMultiplayerTtt.Game{}
    assign(socket, game: game, status_message: get_status_message(game))
  end

  defp get_status_message(game) do
    case {game.winning_player, game.current_player} do
      {:player_x, _} -> "Player X has won!"
      {:player_o, _} -> "Player O has won!"
      {:drawn, _} -> "Game is drawn!"
      {_, :player_x} -> "Player X to move"
      {_, :player_o} -> "Player O to move"
    end
  end
end
