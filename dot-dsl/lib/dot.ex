defmodule Dot do
  defmacro graph(ast) do
    case ast[:do] do
      {:__block__, _, []} ->
        quote do: %Graph{}

      {:graph, _, [attrs]} ->
        quote do: %Graph{attrs: unquote(attrs)}

      {:--, _, [{start_node, _, _}, {end_node, _, _}]} ->
        quote do: %Graph{edges: [{unquote(start_node), unquote(end_node), []}]}

      {n, _, ctx} when is_atom(ctx) ->
        quote do: %Graph{nodes: [{unquote(n), []}]}

      {n, _, [attrs]} ->
        quote do: %Graph{nodes: [{unquote(n), unquote(attrs)}]}
    end
  end
end
