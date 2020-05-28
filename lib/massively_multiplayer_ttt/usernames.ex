defmodule MassivelyMultiplayerTtt.Usernames do
  use GenServer
  import MassivelyMultiplayerTtt.Messaging

  @process_name :username_server

  ## Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: @process_name)
  end

  def get_new_username() do
    pid = GenServer.whereis(@process_name)
    GenServer.call(pid, :get_new_username)
  end

  def change_username(old_name, new_name) do
    pid = GenServer.whereis(@process_name)
    GenServer.call(pid, {:change_username, old_name, new_name})
  end

  def remove_username(removed_name) do
    pid = GenServer.whereis(@process_name)
    GenServer.call(pid, {:remove_username, removed_name})
  end

  ## Server callbacks

  @impl true
  def init(:ok) do
    {:ok, []}
  end

  @impl true
  def handle_call(:get_new_username, _from, names) do
    new_name = get_random_username(names)
    broadcast_name_added(new_name)
    {:reply, new_name, [new_name | names]}
  end

  @impl true
  def handle_call({:change_username, old_name, new_name}, _from, names) do
    cond do
      new_name in names ->
        {:reply, :name_taken, names}

      old_name in names ->
        position = Enum.find_index(names, fn name -> name == old_name end)
        broadcast_name_changed(old_name, new_name)
        {:reply, :name_successfully_changed, List.replace_at(names, position, new_name)}

      true ->
        broadcast_name_added(new_name)
        {:reply, :new_name_added, [new_name | names]}
    end
  end

  @impl true
  def handle_call({:remove_username, removed_name}, _from, names) do
    broadcast_name_removed(removed_name)
    {:noreply, Enum.reject(names, fn name -> name == removed_name end)}
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
