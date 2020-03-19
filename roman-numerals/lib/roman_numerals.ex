defmodule RomanNumerals do
  @doc """
  Convert the number to a roman number.
  """
  @spec numeral(pos_integer) :: String.t()
  def numeral(number) do
    translate(number, "", [
      {1000, "M"},
      {500, "D"},
      {100, "C"},
      {50, "L"},
      {10, "X"},
      {5, "V"},
      {1, "I"}
    ])
  end

  defp translate(0, acc, _), do: acc

  defp translate(number, acc, [{ten, ten_roman}, {five, five_roman}, {one, one_roman} | t] = dict) do
    case number do
      x when x >= ten ->
        translate(x - ten, acc <> ten_roman, dict)

      x when x >= ten - one ->
        translate(x - (ten - one), acc <> one_roman <> ten_roman, dict)

      x when x >= five ->
        translate(x - five, acc <> five_roman, dict)

      x when x >= five - one ->
        translate(x - (five - one), acc <> one_roman <> five_roman, dict)

      x when x >= one ->
        translate(x - one, acc <> one_roman, dict)

      _ ->
        translate(number, acc, [{one, one_roman} | t])
    end
  end
end
