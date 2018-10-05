defmodule Memory.Store do
  use GenServer

  def registry(id) do
    {:via, Registry, {Memory.Store.Registry, id}}
  end

  # Client

  def game_exists?(id) do
    case Registry.lookup(Memory.Store.Registry, id) do
      [] -> false
      _ -> true
    end
  end

  def new_game(id, state) do
    DynamicSupervisor.start_child(Memory.Store.Supervisor, %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [id, state]}
    })
  end

  def start_link(id, state) do
    GenServer.start_link(__MODULE__, state, name: registry(id))
  end

  def update(id, state) do
    GenServer.cast(registry(id), {:update, state})
  end

  def get(id) do
    GenServer.call(registry(id), :get)
  end

  # Server 
  def init(map) do
    {:ok, map}
  end

  def handle_cast({:update, newState}, _) do
    {:noreply, newState}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
