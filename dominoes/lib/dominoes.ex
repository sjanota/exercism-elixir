defmodule Dominoes do
  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino] | []) :: boolean
  def chain?([]), do: true
  def chain?([{x, x}]), do: true
  def chain?([{first, _} = block | bank]), do: yyy(block, bank, first)
  def chain?(_), do: false

  defp yyy({_, first}, [], first), do: true
  defp yyy({_, _}, [], _), do: false

  defp yyy({_, next}, bank, first) do
    case find_next(bank, next, []) do
      {block, bank} -> yyy(block, bank, first)
      nil -> false
    end
  end

  def find_next([], _, _), do: nil
  def find_next([{next, _} = block | bank], next, acc), do: {block, acc ++ bank}
  def find_next([{x, next} = block | bank], next, acc), do: {{next, x}, acc ++ bank}
  def find_next([{_, _} = block | bank], next, acc), do: find_next(bank, next, [block | acc])
end
