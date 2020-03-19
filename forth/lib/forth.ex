defmodule Forth do
  @opaque evaluator :: %Forth{}

  defstruct stack: []

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
  def eval(ev, text), do: eval(ev, text, nil)

  # Empty
  defp eval(ev, <<>>, current) do
    process(ev, current)
  end

  # Number
  defp eval(ev, <<c::utf8, rest::binary>>, nil) when c >= ?0 and c <= ?9 do
    eval(ev, rest, {:number, <<c>>})
  end

  defp eval(ev, <<c::utf8, rest::binary>>, {:number, acc}) when c >= ?0 and c <= ?9 do
    eval(ev, rest, {:number, acc <> <<c>>})
  end

  defp eval(ev, <<c::utf8, rest::binary>>, {:number, acc}) when c >= ?a and c <= ?z or c >= ?A and c <= ?Z do
    eval(ev, rest, {:number, acc <> <<c>>})
  end

  # Arithmetic
  defp eval(ev, "+" <> rest, nil), do: eval(ev, rest, :add)
  defp eval(ev, "-" <> rest, nil), do: eval(ev, rest, :subtract)
  defp eval(ev, "*" <> rest, nil), do: eval(ev, rest, :multiply)
  defp eval(ev, "/" <> rest, nil), do: eval(ev, rest, :divide)

  # Non-word character
  defp eval(ev, <<_::utf8, rest::binary>>, current) do
    eval(process(ev, current), rest, nil)
  end

  defp process(ev, nil), do: ev

  defp process(ev, {:number, n}) do
    %{ev | stack: [String.to_integer(n) | ev.stack]}
  end

  defp process(%{stack: [x, y | t]} = ev, :add) do
    %{ev | stack: [y + x | t]}
  end

  defp process(%{stack: [x, y | t]} = ev, :subtract) do
    %{ev | stack: [y - x | t]}
  end

  defp process(%{stack: [x, y | t]} = ev, :multiply) do
    %{ev | stack: [y * x | t]}
  end

  defp process(%{stack: [0 | t]} = ev, :divide) do
    raise Forth.DivisionByZero
  end

  defp process(%{stack: [x, y | t]} = ev, :divide) do
    %{ev | stack: [div(y, x) | t]}
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
end
