defmodule MassivelyMultiplayerTtt.UsernameServer do
  use GenServer
  import MassivelyMultiplayerTtt.Messaging

  ## Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def monitor() do
    GenServer.call(__MODULE__, :monitor)
  end

  def get_new_username() do
    GenServer.call(__MODULE__, :get_new_username)
  end

  def get_all_usernames() do
    GenServer.call(__MODULE__, :get_all_usernames)
  end

  def change_username(old_name, new_name) do
    GenServer.call(__MODULE__, {:change_username, old_name, new_name})
  end

  ## Server callbacks

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:monitor, {view_pid, _ref}, state) do
    _ = Process.monitor(view_pid)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:get_new_username, {view_pid, _ref}, state) do
    new_name =
      state
      |> all_usernames
      |> get_random_username

    broadcast_name_added(new_name)

    new_state = Map.put(state, view_pid, new_name)
    {:reply, new_name, new_state}
  end

  @impl true
  def handle_call(:get_all_usernames, _from, state) do
    {:reply, all_usernames(state), state}
  end

  @impl true
  def handle_call({:change_username, old_name, new_name}, {view_pid, _ref}, state) do
    names = all_usernames(state)

    cond do
      new_name in names ->
        {:reply, :name_taken, names}

      old_name in names ->
        broadcast_name_changed(old_name, new_name)
        new_state = Map.put(state, view_pid, new_name)
        {:reply, :name_successfully_changed, new_state}

      true ->
        broadcast_name_added(new_name)
        new_state = Map.put(state, view_pid, new_name)
        {:reply, new_name, new_state}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, view_pid, _reason}, state) do
    {removed_name, new_state} = Map.pop(state, view_pid)

    broadcast_name_removed(removed_name)

    {:noreply, new_state}
  end

  ## Private functions
  defp all_usernames(state) do
    Map.values(state)
  end

  defp get_random_username(existing_usernames) do
    number = Enum.random(1000..9999)
    username = "User#{number}"

    if username in existing_usernames do
      get_random_username(existing_usernames)
    else
      username
    end
  end
end
