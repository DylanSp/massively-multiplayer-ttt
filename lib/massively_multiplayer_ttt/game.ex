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
          game =
            if game.current_player == :player_x do
              %{
                game
                | board: List.replace_at(game.board, cell_num, :x),
                  current_player: :player_o
              }
            else
              %{
                game
                | board: List.replace_at(game.board, cell_num, :o),
                  current_player: :player_x
              }
            end

          game = check_for_end(game)

          case game.winning_player do
            :unfinished ->
              {:waiting_for_move, game}

            _ ->
              {:game_finished, game}
          end
        end

      _x_or_o ->
        {:square_filled, game}
    end
  end

  defp check_for_end(game) do
    case game.board do
      [:x, :x, :x, _, _, _, _, _, _] ->
        %{game | winning_player: :player_x}

      [_, _, _, :x, :x, :x, _, _, _] ->
        %{game | winning_player: :player_x}

      [_, _, _, _, _, _, :x, :x, :x] ->
        %{game | winning_player: :player_x}

      [:x, _, _, :x, _, _, :x, _, _] ->
        %{game | winning_player: :player_x}

      [_, :x, _, _, :x, _, _, :x, _] ->
        %{game | winning_player: :player_x}

      [_, _, :x, _, _, :x, _, _, :x] ->
        %{game | winning_player: :player_x}

      [:x, _, _, _, :x, _, _, _, :x] ->
        %{game | winning_player: :player_x}

      [_, _, :x, _, :x, _, :x, _, _] ->
        %{game | winning_player: :player_x}

      [:o, :o, :o, _, _, _, _, _, _] ->
        %{game | winning_player: :player_o}

      [_, _, _, :o, :o, :o, _, _, _] ->
        %{game | winning_player: :player_o}

      [_, _, _, _, _, _, :o, :o, :o] ->
        %{game | winning_player: :player_o}

      [:o, _, _, :o, _, _, :o, _, _] ->
        %{game | winning_player: :player_o}

      [_, :o, _, _, :o, _, _, :o, _] ->
        %{game | winning_player: :player_o}

      [_, _, :o, _, _, :o, _, _, :o] ->
        %{game | winning_player: :player_o}

      [:o, _, _, _, :o, _, _, _, :o] ->
        %{game | winning_player: :player_o}

      [_, _, :o, _, :o, _, :o, _, _] ->
        %{game | winning_player: :player_o}

      board ->
        if :empty in board do
          game
        else
          %{game | winning_player: :drawn}
        end
    end
  end
end
