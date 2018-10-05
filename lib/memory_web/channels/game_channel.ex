defmodule MemoryWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:" <> room_id, auth_message, socket) do
    if Memory.Store.game_exists?(room_id) do
      state = Memory.Store.get(room_id)

      socket =
        socket
        |> assign(:id, room_id)
        |> assign(:state, state)

      {:ok, Memory.Game.state_to_client(state), socket}
    else
      state = %{
        board: Memory.Game.createBoard(),
        solved: MapSet.new(),
        clickCounter: 0,
        prevGuessIndex: nil,
        incorrectGuess: nil
      }

      socket =
        socket
        |> assign(:state, state)
        |> assign(:id, room_id)

      Memory.Store.new_game(room_id, state)
      {:ok, Memory.Game.state_to_client(state), socket}
    end
  end

  def handle_in("guess", %{"guessIndex" => guessIndex}, socket) do
    prevState = socket.assigns[:state]
    newState = Memory.Game.guess(prevState, guessIndex)
    socket = socket |> assign(:state, newState)

    Memory.Store.update(
      socket.assigns[:id],
      newState
      |> Map.put(:prevGuessIndex, nil)
      |> Map.put(:incorrectGuess, nil)
    )

    {:reply, {:ok, Memory.Game.state_to_client(newState)}, socket}
  end

  def handle_in("reset", _, socket) do
    newState = %{
      board: Memory.Game.createBoard(),
      solved: MapSet.new(),
      clickCounter: 0,
      prevGuessIndex: nil,
      incorrectGuess: nil
    }

    socket = socket |> assign(:state, newState)

    Memory.Store.update(
      socket.assigns[:id],
      newState
      |> Map.put(:prevGuessIndex, nil)
      |> Map.put(:incorrectGuess, nil)
    )

    {:reply, {:ok, Memory.Game.state_to_client(newState)}, socket}
  end
end
