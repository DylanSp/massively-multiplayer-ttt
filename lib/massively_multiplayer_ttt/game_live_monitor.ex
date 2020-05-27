# Borrowed from https://github.com/phoenixframework/phoenix_live_view/issues/123

defmodule GameLiveMonitor do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: {:global, __MODULE__})
  end

  def monitor(socket_id, game_pid) do
    pid = GenServer.whereis({:global, __MODULE__})
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
