defmodule Dominoes do
  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino] | []) :: boolean
  def chain?([]), do: true

  def chain?([{left, right} = h | t]),
    do: chain?(h, t, [], left) or chain?(reverse(h), t, [], right)

  def chain?(_), do: false

  @spec chain?(domino, remaining :: [domino], checked :: [domino], first_number :: 1..6) ::
          boolean
  defp chain?(domino, remaining, checked, first_number)

  defp chain?({_, first_number}, [], [], first_number), do: true
  defp chain?(_, [], _, _), do: false

  defp chain?({_, right} = domino, [h | t], checked, first_number) do
    is_chain =
      case h do
        {^right, _} ->
          chain?(h, checked ++ t, [], first_number)

        {_, ^right} ->
          chain?(reverse(h), checked ++ t, [], first_number)

        _ ->
          false
      end

    is_chain or chain?(domino, t, [h | checked], first_number)
  end

  @spec reverse(domino) :: domino
  defp reverse({left, right}), do: {right, left}
end
