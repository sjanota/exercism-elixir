defmodule Dot do
  defmacro graph(ast) do
    _process([ast[:do]], quote(do: %Graph{}))
  end

  def _process([exp | t], acc), do: _process(t, _process_single(exp, acc))

  def _process([], acc) do
    quote do
      %{
        unquote(acc)
        | attrs: List.keysort(unquote(acc).attrs, 0),
          nodes: List.keysort(unquote(acc).nodes, 0)
      }
    end
  end

  defp _process_single({:__block__, _, block}, acc), do: _process(block, acc)

  defp _process_single({:--, _, [{start_node, _, _}, {end_node, _, nil}]}, acc)
       when is_atom(start_node) and is_atom(end_node) do
    _process_edge(start_node, end_node, quote(do: []), acc)
  end

  defp _process_single({:--, _, [{start_node, _, _}, {end_node, _, [attrs]}]}, acc)
       when is_atom(start_node) and is_atom(end_node) do
    _process_edge(start_node, end_node, attrs, acc)
  end

  defp _process_single({:graph, _, [attrs]}, acc) do
    quote do: %{
            unquote(acc)
            | attrs: Keyword.merge(unquote(acc).attrs, unquote(attrs))
          }
  end

  defp _process_single({n, _, nil}, acc) do
    quote do: %{unquote(acc) | nodes: [{unquote(n), []}]}
  end

  defp _process_single({n, _, [attrs]}, acc) when is_list(attrs) do
    unless _is_keyword_list(attrs) do
      raise ArgumentError
    end

    quote do
      graph = unquote(acc)

      %{
        graph
        | nodes: Keyword.put(graph.nodes, unquote(n), unquote(attrs))
      }
    end
  end

  defp _process_single(_, _), do: raise(ArgumentError)

  defp _process_edge(start_node, end_node, attrs, acc) do
    quote do
      graph = unquote(acc)

      %{
        graph
        | edges: [{unquote(start_node), unquote(end_node), unquote(attrs)} | graph.edges]
      }
    end
  end

  defp _is_keyword_list([]), do: true
  defp _is_keyword_list([{a, _} | t]) when is_atom(a), do: _is_keyword_list(t)
  defp _is_keyword_list(_), do: false
end
