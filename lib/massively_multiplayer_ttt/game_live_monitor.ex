# Borrowed from https://github.com/phoenixframework/phoenix_live_view/issues/123

defmodule MassivelyMultiplayerTtt.GameLiveMonitor do
  use GenServer
  import MassivelyMultiplayerTtt.Messaging

  @process_name :game_live_monitor

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: :game_live_monitor)
  end

  def monitor(socket_id, game_pid) do
    pid = GenServer.whereis(@process_name)
    GenServer.call(pid, {:monitor, {socket_id, game_pid}})
  end

  def init(_) do
    subscribe_to_names()
    {:ok, %{views: %{}, usernames: %{}}}
  end

  def handle_call({:monitor, {socket_id, game_pid}}, {view_pid, _ref}, %{views: views} = state) do
    mref = Process.monitor(view_pid)
    {:reply, :ok, %{state | views: Map.put(views, view_pid, {socket_id, game_pid, mref})}}
  end

  def handle_info({:DOWN, _ref, :process, view_pid, _reason}, state) do
    {{_socket_id, _game_pid, _mref}, new_views} = Map.pop(state.views, view_pid)
    {removed_name, new_usernames} = Map.pop(state.usernames, view_pid)

    broadcast_name_removed(removed_name, view_pid)

    new_state = %{state | views: new_views, usernames: new_usernames}
    {:noreply, new_state}
  end

  def handle_info({:new_name, name, view_pid}, state) do
    new_usernames = Map.put(state.usernames, view_pid, name)
    new_state = %{state | usernames: new_usernames}
    {:noreply, new_state}
  end

  def handle_info({:name_changed, _old_name, new_name, view_pid}, state) do
    new_usernames = Map.put(state.usernames, view_pid, new_name)
    new_state = %{state | usernames: new_usernames}
    {:noreply, new_state}
  end

  # Ignore message, all taken care of in the handler for :DOWN
  def handle_info({:name_removed, _name, _view_pid}, state) do
    {:noreply, state}
  end
end
