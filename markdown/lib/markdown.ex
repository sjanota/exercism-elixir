defmodule Markdown do
  @doc """
    Parses a given string with Markdown syntax and returns the associated HTML for that string.

    ## Examples

    iex> Markdown.parse("This is a paragraph")
    "<p>This is a paragraph</p>"

    iex> Markdown.parse("#Header!\n* __Bold Item__\n* _Italic Item_")
    "<h1>Header!</h1><ul><li><em>Bold Item</em></li><li><i>Italic Item</i></li></ul>"
  """
  @spec parse(String.t()) :: String.t()
  def parse(text), do: parse("\n" <> text, [], "")

  defp parse("", [], acc), do: acc

  # Header
  defp parse("\n#" <> text, ctx, acc),
    do: parse(text, [{:header_start, 1} | ctx], acc)

  defp parse("#" <> text, [{:header_start, level} | ctx], acc),
    do: parse(text, [{:header_start, level + 1} | ctx], acc)

  defp parse(" " <> text, [{:header_start, level} | ctx], acc),
    do: parse(text, [{:header, level} | ctx], acc <> "<h#{level}>")

  defp parse("\n" <> _ = text, [{:header, level} | ctx], acc),
    do: parse(text, ctx, acc <> "</h#{level}>")

  defp parse("", [{:header, level} | ctx], acc), do: parse("", ctx, acc <> "</h#{level}>")

  # List item
  defp parse("\n* " <> rest, [:ul | _] = ctx, acc),
    do: parse(rest, [:li | ctx], acc <> "<li>")

  defp parse("\n" <> _ = text, [:li | ctx], acc),
    do: parse(text, ctx, acc <> "</li>")

  defp parse("", [:li | ctx], acc), do: parse("", ctx, acc <> "</li>")

  # Unordered list
  defp parse("\n* " <> _ = text, ctx, acc),
    do: parse(text, [:ul | ctx], acc <> "<ul>")

  defp parse("\n" <> _ = text, [:ul | ctx], acc),
    do: parse(text, ctx, acc <> "</ul>")

  defp parse("", [:ul | ctx], acc), do: parse("", ctx, acc <> "</ul>")

  # Paragraph
  defp parse("\n" <> rest, ctx, acc), do: parse(rest, [:paragraph | ctx], acc <> "<p>")
  defp parse("", [:paragraph | ctx], acc), do: parse("", ctx, acc <> "</p>")

  # Bold
  defp parse("__" <> rest, [:bold | ctx], acc), do: parse(rest, ctx, acc <> "</strong>")
  defp parse("__" <> rest, ctx, acc), do: parse(rest, [:bold | ctx], acc <> "<strong>")

  # Italic
  defp parse("_" <> rest, [:italic | ctx], acc), do: parse(rest, ctx, acc <> "</em>")
  defp parse("_" <> rest, ctx, acc), do: parse(rest, [:italic | ctx], acc <> "<em>")

  # Text
  defp parse(text, ctx, acc), do: parse(String.slice(text, 1..-1), ctx, acc <> String.first(text))
end
