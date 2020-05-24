defmodule MassivelyMultiplayerTttWeb.GameLive do
  use MassivelyMultiplayerTttWeb, :live_view
  import MassivelyMultiplayerTtt.Game

  def mount(_params, _session, socket) do
    game = %MassivelyMultiplayerTtt.Game{}
    socket = assign(socket, game: game, status_message: get_status_message(game))
    {:ok, socket}
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

    {:noreply, socket}
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
