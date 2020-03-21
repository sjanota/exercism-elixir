defmodule Dot do
  defmacro graph(ast) do
    nodes =
      case ast[:do] do
        {:__block__, _, []} -> quote do: []
        {n, _, ctx} when is_atom(ctx) -> quote do: [{unquote(n), []}]
        {n, _, [attrs]} -> quote do: [{unquote(n), unquote(attrs)}]
      end

    quote do
      %Graph{nodes: unquote(nodes)}
    end
  end
end
