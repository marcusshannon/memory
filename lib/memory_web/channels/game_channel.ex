defmodule MemoryWeb.RoomChannel do
  use Phoenix.Channel

  def join("game:" <> game, _, socket) do
    if Memory.Store.game_exists?(game) do
      state = Memory.Store.get(game)

      socket =
        socket
        |> assign(:game, game)

      {:ok, Memory.Game.state_to_client(state), socket}
    else
      state = %{
        player_1: nil,
        player_2: nil,
        current_state: "LOBBY",
        board: nil,
        solved: MapSet.new(),
        player_1_points: nil,
        player_2_points: nil,
        turn: nil,
        player_1_first_guess_index: nil,
        player_2_first_guess_index: nil,
        incorrect_guess: nil
      }

      socket =
        socket
        |> assign(:game, game)

      Memory.Store.new_game(game, state)
      {:ok, Memory.Game.state_to_client(state), socket}
    end
  end

  def handle_in(
        "guess",
        %{"guessIndex" => guess_index},
        %{assigns: %{current_user: current_user, game: game}} = socket
      ) do
    prev_state = Memory.Store.get(game)
    new_state = Memory.Game.guess(prev_state, guess_index, current_user)

    Memory.Store.update(
      socket.assigns[:game],
      new_state
    )

    broadcast!(socket, "state_update", Memory.Game.state_to_client(new_state))

    {:noreply, socket}
  end

  def handle_in("join", _, %{assigns: %{current_user: current_user, game: game}} = socket) do
    prev_state = Memory.Store.get(game)

    with {:ok, new_state} <- Memory.Game.join_game(prev_state, current_user) do
      IO.inspect(new_state)

      Memory.Store.update(
        socket.assigns[:game],
        new_state
      )

      broadcast!(socket, "state_update", Memory.Game.state_to_client(new_state))
      {:noreply, socket}
    else
      {:error} -> {:noreply, socket}
    end
  end

  def handle_in("reset", _, socket) do
    new_state = %{
      player_1: nil,
      player_2: nil,
      current_state: "LOBBY",
      board: nil,
      solved: MapSet.new(),
      player_1_points: nil,
      player_2_points: nil,
      turn: nil,
      player_1_first_guess_index: nil,
      player_2_first_guess_index: nil,
      incorrect_guess: nil
    }

    Memory.Store.update(
      socket.assigns[:game],
      new_state
    )

    broadcast!(socket, "state_update", Memory.Game.state_to_client(new_state))
    {:noreply, socket}
  end
end
