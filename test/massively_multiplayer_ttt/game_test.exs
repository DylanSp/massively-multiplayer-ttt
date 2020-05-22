defmodule MassivelyMultiplayerTtt.GameTest do
  use ExUnit.Case, async: true
  import MassivelyMultiplayerTtt.Game

  test "recognizes X's victory" do
    # Arrange
    game = %MassivelyMultiplayerTtt.Game{}

    # Act
    {_, game} = make_move(game, 0)
    {_, game} = make_move(game, 6)
    {_, game} = make_move(game, 1)
    {_, game} = make_move(game, 7)
    {result, game} = make_move(game, 2)

    # Assert
    assert(result == :game_finished)
    assert(game.winning_player == :player_x)
  end

  test "recognizes O's victory" do
    # Arrange
    game = %MassivelyMultiplayerTtt.Game{}

    # Act
    {_, game} = make_move(game, 0)
    {_, game} = make_move(game, 6)
    {_, game} = make_move(game, 1)
    {_, game} = make_move(game, 7)
    {_, game} = make_move(game, 5)
    {result, game} = make_move(game, 8)

    # Assert
    assert(result == :game_finished)
    assert(game.winning_player == :player_o)
  end

  test "recognizes a drawn game" do
    # Arrange
    game = %MassivelyMultiplayerTtt.Game{}

    # Act
    {_, game} = make_move(game, 0)
    {_, game} = make_move(game, 1)
    {_, game} = make_move(game, 3)
    {_, game} = make_move(game, 4)
    {_, game} = make_move(game, 7)
    {_, game} = make_move(game, 6)
    {_, game} = make_move(game, 2)
    {_, game} = make_move(game, 5)
    {result, game} = make_move(game, 8)

    # Assert
    assert(result == :game_finished)
    assert(game.winning_player == :drawn)
  end

  test "returns an error when attempting to move to an already-filled cell" do
    # Arrange
    game = %MassivelyMultiplayerTtt.Game{}

    # Act
    {_, game} = make_move(game, 0)
    {result, _} = make_move(game, 0)

    # Assert
    assert(result == :square_filled)
  end

  test "returns an error when attempting to move in an already completed game" do
    # Arrange
    game = %MassivelyMultiplayerTtt.Game{}

    # Act
    {_, game} = make_move(game, 0)
    {_, game} = make_move(game, 6)
    {_, game} = make_move(game, 1)
    {_, game} = make_move(game, 7)
    {_, game} = make_move(game, 2)
    {result, _} = make_move(game, 5)

    # Assert
    assert(result == :game_already_over)
  end

  test "recognizes X's turn" do
    # Arrange
    game = %MassivelyMultiplayerTtt.Game{}

    # Act
    {_, game} = make_move(game, 0)
    {result, game} = make_move(game, 1)

    # Assert
    assert(result == :waiting_for_move)
    assert(game.current_player == :player_x)
  end

  test "recognizes O's turn" do
    # Arrange
    game = %MassivelyMultiplayerTtt.Game{}

    # Act
    {result, game} = make_move(game, 0)

    # Assert
    assert(result == :waiting_for_move)
    assert(game.current_player == :player_o)
  end
end
