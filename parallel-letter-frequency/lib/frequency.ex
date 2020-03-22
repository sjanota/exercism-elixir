defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, workers) do
    {:ok, texts_server} =
      Agent.start_link(fn ->
        for t <- texts do
          String.downcase(t)
        end
      end)

    my_pid = self()

    workers =
      for _ <- 1..workers do
        spawn(fn -> worker_loop(my_pid, texts_server, %{}) end)
      end

    merged =
      List.foldl(
        workers,
        %{},
        fn worker, acc ->
          receive do
            {^worker, counters} -> merge(acc, counters)
          end
        end
      )

    :ok = Agent.stop(texts_server)
    merged
  end

  defp get_next_char([]), do: {nil, []}
  defp get_next_char(["" | t]), do: get_next_char(t)

  defp get_next_char([text | t]) do
    {c, rest} = String.split_at(text, 1)
    {c, [rest | t]}
  end

  defp worker_loop(root_pid, server, counters) do
    rsp = Agent.get_and_update(server, &get_next_char/1)

    case rsp do
      nil ->
        send(root_pid, {self(), counters})

      c ->
        if String.match?(c, ~r/^\p{L}$/u) do
          count = Map.get(counters, c, 0)
          counters = Map.put(counters, c, count + 1)
          worker_loop(root_pid, server, counters)
        else
          worker_loop(root_pid, server, counters)
        end
    end
  end

  defp merge(base, incoming) do
    List.foldl(
      Map.to_list(incoming),
      base,
      fn {k, v}, acc ->
        count = Map.get(acc, k, 0)
        Map.put(acc, k, count + v)
      end
    )
  end
end
