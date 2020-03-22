defmodule Dominoes do
  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino] | []) :: boolean
  def chain?([]), do: true
  def chain?([{left, right} = h | t]), do: chain?(h, t, left) or chain?(reverse(h), t, right)
  def chain?(_), do: false

  @spec chain?(domino, dominoes :: [domino], first_number :: 1..6) :: boolean
  defp chain?(domino, dominoes, first_number)

  defp chain?({_, first_number}, [], first_number), do: true

  defp chain?({left, right}, dominoes, first_number) do
    matching = take_matching(dominoes, right)
    Enum.any?(matching, fn {domino, remaining} -> chain?(domino, remaining, first_number) end)
  end

  @spec take_matching(dominoes :: [domino], number_to_match :: 1..6) :: [
          {match :: domino, remaining :: [domino]}
        ]
  def take_matching(dominoes, number_to_match),
    do: take_matching(dominoes, number_to_match, [], [])

  def take_matching([], _, _, acc), do: acc

  def take_matching([{match, _} = h | t], match, checked, acc),
    do: take_matching(t, match, [h | checked], [{h, checked ++ t} | acc])

  def take_matching([{_, match} = h | t], match, checked, acc),
    do: take_matching(t, match, [h | checked], [{reverse(h), checked ++ t} | acc])

  def take_matching([h | t], next, checked, acc),
    do: take_matching(t, next, [h | checked], acc)

  @spec reverse(domino) :: domino
  defp reverse({left, right}), do: {right, left}
end
