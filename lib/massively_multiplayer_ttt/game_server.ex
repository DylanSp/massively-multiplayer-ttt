defmodule MassivelyMultiplayerTtt.GameServer do
  use GenServer
  import MassivelyMultiplayerTtt.Messaging
  alias MassivelyMultiplayerTtt.Game, as: Game

  @process_name :game_server

  ## Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: @process_name)
  end

  def start_new_game() do
    pid = GenServer.whereis(@process_name)
    GenServer.call(pid, :start_new_game)
  end

  def get_game_status() do
    pid = GenServer.whereis(@process_name)
    GenServer.call(pid, :get_game_status)
  end

  def make_move(cell_num) do
    pid = GenServer.whereis(@process_name)
    GenServer.call(pid, {:make_move, cell_num})
  end

  ## Server callbacks

  @impl true
  def init(:ok) do
    {:ok, %Game{}}
  end

  @impl true
  def handle_call(:start_new_game, _from, _game) do
    broadcast_new_game()
    {:reply, :new_game_started, %Game{}}
  end

  @impl true
  def handle_call(:get_game_status, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_call({:make_move, cell_num}, _from, game) do
    {move_result, new_game} = Game.make_move(game, cell_num)

    case move_result do
      :game_already_over ->
        {:reply, :game_already_over, new_game}

      :square_filled ->
        {:reply, :square_filled, new_game}

      :game_finished ->
        broadcast_game_update(new_game)
        {:reply, :game_finished, new_game}

      :waiting_for_move ->
        broadcast_game_update(new_game)
        {:reply, :waiting_for_move, new_game}
    end
  end
end
