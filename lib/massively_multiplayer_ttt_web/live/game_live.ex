defmodule MassivelyMultiplayerTttWeb.GameLive do
  use MassivelyMultiplayerTttWeb, :live_view
  use Phoenix.HTML
  import MassivelyMultiplayerTtt.GameServer
  import MassivelyMultiplayerTtt.Messaging
  import MassivelyMultiplayerTtt.UsernameServer

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        username: "Connecting...",
        all_names: [],
        status_message: "Connecting...",
        game: %MassivelyMultiplayerTtt.Game{}
      )

    if connected?(socket) do
      monitor()
      subscribe_to_game()
      subscribe_to_names()
      username = get_new_username()
      game = get_game_status()
      all_names = get_all_usernames() |> sort_usernames

      socket =
        assign(socket,
          game: game,
          username: username,
          all_names: all_names,
          status_message: get_status_message(game)
        )

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  ## game-related UI callbacks

  def handle_event("new_game", _, socket) do
    _ = start_new_game()
    {:noreply, socket}
  end

  def handle_event("click_cell", %{"cell-num" => cell_num}, socket) do
    cell_num = String.to_integer(cell_num)
    move_result = make_move(cell_num)

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
          socket
      end

    {:noreply, socket}
  end

  ## Name-related UI callbacks

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

  ## Game-related internal messaging callbacks

  def handle_info(:new_game, socket) do
    game = %MassivelyMultiplayerTtt.Game{}
    socket = assign(socket, game: game, status_message: get_status_message(game))
    {:noreply, socket}
  end

  def handle_info({:game_updated, game}, socket) do
    # TODO Flash message if game has ended
    socket = assign(socket, game: game, status_message: get_status_message(game))
    {:noreply, socket}
  end

  ## Name-related internal messaging callbacks

  def handle_info({:new_name, new_name}, socket) do
    # Prevent double-add if we're the one who originally fired the new_name event
    if new_name == socket.assigns.username do
      {:noreply, socket}
    else
      all_names = [new_name | socket.assigns.all_names] |> sort_usernames
      socket = assign(socket, all_names: all_names)
      {:noreply, socket}
    end
  end

  def handle_info({:name_changed, old_name, new_name}, socket) do
    position = Enum.find_index(socket.assigns.all_names, fn name -> name == old_name end)

    all_names =
      socket.assigns.all_names
      |> List.replace_at(position, new_name)
      |> sort_usernames

    socket = assign(socket, all_names: all_names)

    {:noreply, socket}
  end

  def handle_info({:name_removed, name}, socket) do
    socket = assign(socket, all_names: List.delete(socket.assigns.all_names, name))
    {:noreply, socket}
  end

  ## Private functions

  defp get_status_message(game) do
    case {game.winning_player, game.current_player} do
      {:player_x, _} -> "Player X has won!"
      {:player_o, _} -> "Player O has won!"
      {:drawn, _} -> "Game is drawn!"
      {_, :player_x} -> "Player X to move"
      {_, :player_o} -> "Player O to move"
    end
  end

  defp sort_usernames(names) do
    Enum.sort_by(names, &String.capitalize/1)
  end
end
