# Borrowed from https://github.com/phoenixframework/phoenix_live_view/issues/123

defmodule MassivelyMultiplayerTtt.GameLiveMonitor do
  use GenServer

  @process_name :game_live_monitor

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: :game_live_monitor)
  end

  def monitor(socket_id, game_pid) do
    pid = GenServer.whereis(@process_name)
    GenServer.call(pid, {:monitor, {socket_id, game_pid}})
  end

  def init(_) do
    {:ok, %{views: %{}}}
  end

  def handle_call({:monitor, {socket_id, game_pid}}, {view_pid, _ref}, %{views: views} = state) do
    mref = Process.monitor(view_pid)
    {:reply, :ok, %{state | views: Map.put(views, view_pid, {socket_id, game_pid, mref})}}
  end

  def handle_info({:DOWN, _ref, :process, view_pid, _reason}, state) do
    IO.puts(":DOWN #{inspect(view_pid)}")
    {{_socket_id, _game_pid, _mref}, new_views} = Map.pop(state.views, view_pid)
    # more logic ...
    new_state = %{state | views: new_views}
    {:noreply, new_state}
  end
end
