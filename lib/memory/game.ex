defmodule Memory.Game do
  def createBoard() do
    size = 8

    Enum.concat(1..size, 1..size)
    |> Enum.shuffle()
  end

  def guess(%{turn: user} = prev_state, guess_index, current_user) when user == current_user do
    if prev_state[:player_1] == current_user do
      player_1_guess(prev_state, guess_index)
    else
      player_2_guess(prev_state, guess_index)
    end
  end

  def guess(prev_state, _, _) do
    prev_state
    |> Map.put(:incorrect_guess, nil)
  end

  def player_1_guess(
        %{player_1_first_guess_index: player_1_first_guess_index} = prev_state,
        guess_index
      )
      when is_nil(player_1_first_guess_index) do
    prev_state
    |> Map.put(:player_1_first_guess_index, guess_index)
    |> Map.put(:incorrect_guess, nil)
  end

  def player_1_guess(
        %{player_1_first_guess_index: player_1_first_guess_index, board: board} = prev_state,
        guess_index
      ) do
    if Enum.at(board, player_1_first_guess_index) == Enum.at(board, guess_index) and
         player_1_first_guess_index !== guess_index do
      prev_state
      |> Map.put(:player_1_first_guess_index, nil)
      |> Map.update!(:player_1_points, &(&1 + 1))
      |> Map.update!(:solved, &MapSet.put(&1, player_1_first_guess_index))
      |> Map.update!(:solved, &MapSet.put(&1, guess_index))
      |> Map.put(:turn, prev_state[:player_2])
    else
      prev_state
      |> Map.put(:player_1_first_guess_index, nil)
      |> Map.put(:incorrect_guess, %{
        guess_index => Enum.at(board, guess_index),
        player_1_first_guess_index => Enum.at(board, player_1_first_guess_index)
      })
      |> Map.put(:turn, prev_state[:player_2])
    end
  end

  def player_2_guess(
        %{player_2_first_guess_index: player_2_first_guess_index} = prev_state,
        guess_index
      )
      when is_nil(player_2_first_guess_index) do
    prev_state
    |> Map.put(:player_2_first_guess_index, guess_index)
    |> Map.put(:incorrect_guess, nil)
  end

  def player_2_guess(
        %{player_2_first_guess_index: player_2_first_guess_index, board: board} = prev_state,
        guess_index
      ) do
    if Enum.at(board, player_2_first_guess_index) == Enum.at(board, guess_index) and
         player_2_first_guess_index !== guess_index do
      prev_state
      |> Map.put(:player_2_first_guess_index, nil)
      |> Map.update!(:player_2_points, &(&1 + 1))
      |> Map.update!(:solved, &MapSet.put(&1, player_2_first_guess_index))
      |> Map.update!(:solved, &MapSet.put(&1, guess_index))
      |> Map.put(:turn, prev_state[:player_1])
    else
      prev_state
      |> Map.put(:player_2_first_guess_index, nil)
      |> Map.put(:incorrect_guess, %{
        guess_index => Enum.at(board, guess_index),
        player_2_first_guess_index => Enum.at(board, player_2_first_guess_index)
      })
      |> Map.put(:turn, prev_state[:player_1])
    end
  end

  def join_game(%{current_state: "LOBBY", player_1: nil} = prev_state, current_user) do
    new_state =
      prev_state
      |> Map.put(:player_1, current_user)

    {:ok, new_state}
  end

  def join_game(%{current_state: "LOBBY", player_2: nil} = prev_state, current_user) do
    if prev_state[:player_1] != current_user do
      new_state =
        prev_state
        |> Map.put(:player_2, current_user)
        |> Map.put(:current_state, "GAME")
        |> Map.merge(%{
          board: Memory.Game.createBoard(),
          solved: MapSet.new(),
          player_1_points: 0,
          player_2_points: 0,
          turn: prev_state[:player_1],
          player_1_first_guess_index: nil,
          player_2_first_guess_index: nil,
          incorrect_guess: nil
        })

      {:ok, new_state}
    else
      {:error}
    end
  end

  def state_to_client(%{
        board: board,
        solved: solved,
        player_1_points: player_1_points,
        player_2_points: player_2_points,
        turn: turn,
        player_1_first_guess_index: player_1_first_guess_index,
        player_2_first_guess_index: player_2_first_guess_index,
        player_1: player_1,
        player_2: player_2,
        current_state: current_state,
        incorrect_guess: incorrect_guess
      }) do
    solvedMap =
      MapSet.to_list(solved)
      |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x, Enum.at(board, x)) end)

    base = %{
      solved: solvedMap,
      player1Points: player_1_points,
      player2Points: player_2_points,
      turn: turn,
      player1: player_1,
      player2: player_2,
      player1FirstGuessIndex: nil,
      player2FirstGuessIndex: nil,
      currentState: current_state,
      incorrectGuess: incorrect_guess
    }

    cond do
      not is_nil(player_1_first_guess_index) and not is_nil(player_2_first_guess_index) ->
        Map.put(base, :player1FirstGuessIndex, %{
          player_1_first_guess_index => Enum.at(board, player_1_first_guess_index)
        })
        |> Map.put(:player2FirstGuessIndex, %{
          player_2_first_guess_index => Enum.at(board, player_2_first_guess_index)
        })

      not is_nil(player_1_first_guess_index) ->
        Map.put(base, :player1FirstGuessIndex, %{
          player_1_first_guess_index => Enum.at(board, player_1_first_guess_index)
        })

      not is_nil(player_2_first_guess_index) ->
        Map.put(base, :player2FirstGuessIndex, %{
          player_2_first_guess_index => Enum.at(board, player_2_first_guess_index)
        })

      true ->
        base
    end
  end
end
