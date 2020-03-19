defmodule WordCount do
  @doc """
  Count the number of words in the sentence.

  Words are compared case-insensitively.
  """
  @spec count(String.t()) :: map
  def count(sentence) do
    sentence
    |> String.split(~r/[\s_]/)
    |> Enum.flat_map(&normalize/1)
    |> Enum.reduce(%{}, &inc_word_counter/2)
  end

  @spec normalize(String.t()) :: [String.t()]
  defp normalize(word) do
    normalized =
      word
      |> String.downcase
      |> String.replace(~r/[:!&@$%^&,]+/, "")

    case normalized do
      "" -> []
      _ -> [normalized]
    end
  end

  @spec inc_word_counter(String.t(), map) :: map
  defp inc_word_counter(word, counters) do
    new =
      case counters[word] do
        nil -> 1
        old -> old + 1
      end

    Map.put(counters, word, new)
  end
end
