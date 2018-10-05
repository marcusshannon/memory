defmodule Memory.Game do
  def randomNumber do
    Enum.random(1..8)
  end

  def findRandom(used) do
    num = randomNumber()

    case(Map.get(used, num)) do
      count when count == 2 -> findRandom(used)
      _ -> num
    end
  end

  def createBoard(board, used) when length(board) < 16 do
    num = findRandom(used)

    createBoard(
      [num | board],
      Map.update(used, num, 1, &(&1 + 1))
    )
  end

  def createBoard(board, _), do: board

  def createBoard() do
    num = randomNumber()
    createBoard([num], %{num => 1})
  end

  def init() do
    %{prev_guess: nil, board: createBoard}
  end

  def guess(%{prevGuessIndex: prevGuessIndex} = prevState, guessIndex)
      when is_nil(prevGuessIndex) do
    prevState
    |> Map.put(:prevGuessIndex, guessIndex)
    |> Map.put(:incorrectGuess, nil)
    |> Map.update!(:clickCounter, &(&1 + 1))
  end

  def guess(
        %{
          prevGuessIndex: prevGuessIndex,
          board: board
        } = prevState,
        guessIndex
      ) do
    guess(
      prevState,
      Enum.at(board, prevGuessIndex),
      prevGuessIndex,
      Enum.at(board, guessIndex),
      guessIndex
    )
  end

  def guess(prevState, prevGuess, prevGuessIndex, guess, guessIndex)
      when prevGuess == guess and prevGuessIndex != guessIndex do
    prevState
    |> Map.update!(:solved, &MapSet.put(&1, guessIndex))
    |> Map.update!(:solved, &MapSet.put(&1, prevGuessIndex))
    |> Map.put(:prevGuessIndex, nil)
    |> Map.update!(:clickCounter, &(&1 + 1))
  end

  def guess(%{board: board} = prevState, prevGuess, prevGuessIndex, guess, guessIndex) do
    prevState
    |> Map.update!(:clickCounter, &(&1 + 1))
    |> Map.put(:prevGuessIndex, nil)
    |> Map.put(:incorrectGuess, %{
      prevGuessIndex => Enum.at(board, prevGuessIndex),
      guessIndex => Enum.at(board, guessIndex)
    })
  end

  def state_to_client(
        %{
          solved: solved,
          clickCounter: clickCounter,
          prevGuessIndex: prevGuessIndex,
          board: board,
          incorrectGuess: incorrectGuess
        } = state
      )
      when is_nil(prevGuessIndex) do
    solvedMap =
      MapSet.to_list(solved)
      |> Enum.reduce(%{}, fn index, acc -> Map.put(acc, index, Enum.at(board, index)) end)

    %{
      solved: solvedMap,
      clickCounter: clickCounter,
      prevGuess: nil,
      incorrectGuess: incorrectGuess
    }
  end

  def state_to_client(
        %{
          solved: solved,
          clickCounter: clickCounter,
          prevGuessIndex: prevGuessIndex,
          board: board,
          incorrectGuess: incorrectGuess
        } = state
      ) do
    solvedMap =
      MapSet.to_list(solved)
      |> Enum.reduce(%{}, fn index, acc -> Map.put(acc, index, Enum.at(board, index)) end)

    prevGuessMap = %{index: prevGuessIndex, value: Enum.at(board, prevGuessIndex)}

    %{
      solved: solvedMap,
      clickCounter: clickCounter,
      prevGuess: prevGuessMap,
      incorrectGuess: incorrectGuess
    }
  end
end
