defmodule MassivelyMultiplayerTtt.Game do
  defstruct current_player: :player_x,
            winning_player: :unfinished,
            board: List.duplicate(:empty, 9)

  def make_move(game, cell_num) when cell_num >= 0 and cell_num <= 8 do
    case Enum.at(game.board, cell_num) do
      :empty ->
        if game.winning_player != :unfinished do
          {:game_already_over, game}
        else
          game = update_game_state(game, cell_num)

          case check_for_end(game.board) do
            :unfinished ->
              {:waiting_for_move, game}

            :drawn ->
              {:game_finished, %{game | winning_player: :drawn}}

            :x ->
              {:game_finished, %{game | winning_player: :player_x}}

            :o ->
              {:game_finished, %{game | winning_player: :player_o}}
          end
        end

      _x_or_o ->
        {:square_filled, game}
    end
  end

  defp update_game_state(%{current_player: :player_x} = game, cell_num) do
    %{game | board: List.replace_at(game.board, cell_num, :x), current_player: :player_o}
  end

  defp update_game_state(%{current_player: :player_o} = game, cell_num) do
    %{game | board: List.replace_at(game.board, cell_num, :o), current_player: :player_x}
  end

  # Horizontals
  defp check_for_end([a, a, a, _, _, _, _, _, _]) when a == :x or a == :o, do: a
  defp check_for_end([_, _, _, a, a, a, _, _, _]) when a == :x or a == :o, do: a
  defp check_for_end([_, _, _, _, _, _, a, a, a]) when a == :x or a == :o, do: a
  # Verticals
  defp check_for_end([a, _, _, a, _, _, a, _, _]) when a == :x or a == :o, do: a
  defp check_for_end([_, a, _, _, a, _, _, a, _]) when a == :x or a == :o, do: a
  defp check_for_end([_, _, a, _, _, a, _, _, a]) when a == :x or a == :o, do: a
  # Diagonals
  defp check_for_end([a, _, _, _, a, _, _, _, a]) when a == :x or a == :o, do: a
  defp check_for_end([_, _, a, _, a, _, a, _, _]) when a == :x or a == :o, do: a

  defp check_for_end(board) do
    if :empty in board do
      :unfinished
    else
      :drawn
    end
  end
end
