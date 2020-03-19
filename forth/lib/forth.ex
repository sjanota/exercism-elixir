defmodule Forth do
  alias Forth.Word
  @opaque evaluator :: %Forth{}

  defstruct stack: [],
            words: %{
              "+" => &Word.add/1,
              "-" => &Word.subtract/1,
              "*" => &Word.multiply/1,
              "/" => &Word.divide/1,
              "dup" => &Word.dup/1,
              "drop" => &Word.drop/1,
              "swap" => &Word.swap/1,
              "over" => &Word.over/1
            }

  @doc """
  Create a new evaluator.
  """
  @spec new() :: evaluator
  def new() do
    %Forth{}
  end

  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  @spec eval(evaluator, String.t()) :: evaluator
  def eval(ev, text), do: process(ev, tokenize(text))

  defp tokenize(text) do
    String.chunk(text, :printable)
    |> Enum.flat_map(&String.split/1)
    |> Enum.filter(&String.printable?/1)
  end

  defp process(ev, []), do: ev

  defp process(ev, [":", name | tokens]) do
    {word_fn, tokens} = process_word_body(tokens)
    name = String.downcase(name)

    case Integer.parse(name) do
      {_, _} ->
        raise Forth.InvalidWord

      :error ->
        ev = %{ev | words: Map.put(ev.words, name, word_fn)}
        process(ev, tokens)
    end
  end

  defp process(ev, [token | rest]) do
    ev =
      case Integer.parse(token) do
        :error -> process_word(ev, token)
        {n, _} -> %{ev | stack: [n | ev.stack]}
      end

    process(ev, rest)
  end

  defp process_word(ev, word) do
    case ev.words[String.downcase(word)] do
      nil -> raise Forth.UnknownWord
      fun -> %{ev | stack: fun.(ev.stack)}
    end
  end

  defp process_word_body(tokens) do
    {body, [";" | tokens]} = Enum.split_while(tokens, &(&1 !== ";"))
    {fn stack -> process(%Forth{stack: stack}, body).stack end, tokens}
  end

  @doc """
  Return the current stack as a string with the element on top of the stack
  being the rightmost element in the string.
  """
  @spec format_stack(evaluator) :: String.t()
  def format_stack(ev) do
    format_stack_inner(ev.stack)
  end

  defp format_stack_inner([]), do: ""
  defp format_stack_inner([h]), do: format_single(h)
  defp format_stack_inner([h | t]), do: format_stack_inner(t) <> " " <> format_single(h)

  defp format_single(e) when is_integer(e), do: Integer.to_string(e)

  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end

  defmodule Word do
    def add([y, x | stack]), do: [x + y | stack]

    def subtract([y, x | stack]), do: [x - y | stack]

    def multiply([y, x | stack]), do: [x * y | stack]

    def divide([0 | _]), do: raise(Forth.DivisionByZero)
    def divide([y, x | stack]), do: [div(x, y) | stack]

    def dup([x | stack]), do: [x, x | stack]
    def dup(_), do: raise(Forth.StackUnderflow)

    def drop([_ | stack]), do: stack
    def drop(_), do: raise(Forth.StackUnderflow)

    def swap([x, y | stack]), do: [y, x | stack]
    def swap(_), do: raise(Forth.StackUnderflow)

    def over([x, y | stack]), do: [y, x, y | stack]
    def over(_), do: raise(Forth.StackUnderflow)
  end
end
