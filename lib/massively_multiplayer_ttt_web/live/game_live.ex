defmodule MassivelyMultiplayerTttWeb.GameLive do
  use MassivelyMultiplayerTttWeb, :live_view
  use Phoenix.HTML
  import MassivelyMultiplayerTtt.Game
  import MassivelyMultiplayerTtt.Messaging

  def mount(_params, _session, socket) do
    if connected?(socket) do
      GameLiveMonitor.monitor(socket.id, self())
      subscribe_to_game()
      subscribe_to_names()
    end

    socket = assign(socket, username: "Connecting...")
    # TODO fix game resetting when new connection made; move to separate game server?
    {:ok, reset_game(socket)}
  end

  def handle_event("change_username", form_data, socket) do
    socket = assign(socket, username: form_data["username"]["value"])
    {:noreply, socket}
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
