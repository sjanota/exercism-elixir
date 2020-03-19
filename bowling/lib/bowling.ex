defmodule Bowling do
  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """

  @type t() :: Bowling
  defstruct prev: nil, score: 0, frame: 1, pending: []

  @spec start() :: t()
  def start do
    %Bowling{}
  end

  @doc """
    Records the number of pins knocked down on a single roll. Returns `any`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """

  @spec roll(t(), integer) :: any | String.t()
  def roll(_, roll) when roll < 0 do
    {:error, "Negative roll is invalid"}
  end

  def roll(%{frame: frame, pending: []}, _) when frame > 10 do
    {:error, "Cannot roll after game is over"}
  end

  def roll(%{prev: prev}, roll) when (prev !== nil and prev + roll > 10) or roll > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end

  def roll(game, roll) do
    game
    |> score_roll(roll)
    |> score_pending(roll)
    |> check_strike_or_spare(roll)
    |> progress_frame(roll)
  end

  defp check_strike_or_spare(%{prev: nil, frame: frame} = game, 10)
       when frame <= 10,
       do: %{game | pending: [:strike | game.pending]}

  defp check_strike_or_spare(%{prev: prev, frame: frame} = game, roll)
       when prev !== nil and prev + roll == 10 and frame <= 10,
       do: %{game | pending: [:spare | game.pending]}

  defp check_strike_or_spare(game, _), do: game

  defp score_roll(%{frame: frame} = game, _) when frame > 10,
    do: game

  defp score_roll(game, roll),
    do: %{game | score: game.score + roll}

  defp score_pending(game, roll),
    do: score_pending(game, roll, [])

  defp score_pending(%{pending: []} = game, _, acc),
    do: %{game | pending: acc}

  defp score_pending(%{pending: [:spare | pending]} = game, roll, acc),
    do: score_pending(%{game | pending: pending, score: game.score + roll}, roll, acc)

  defp score_pending(%{pending: [:strike | pending]} = game, roll, acc),
    do: score_pending(%{game | pending: pending, score: game.score + roll}, roll, [:spare | acc])

  defp progress_frame(%{prev: prev} = game, roll) when roll == 10 or prev != nil,
    do: %{game | frame: game.frame + 1, prev: nil}

  defp progress_frame(game, roll), do: %{game | prev: roll}

  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful message.
  """

  @spec score(t()) :: integer | String.t()
  def score(%{frame: frame, pending: pending}) when frame < 10 or pending !== [] do
    {:error, "Score cannot be taken until the end of the game"}
  end

  def score(game) do
    game.score
  end
end
