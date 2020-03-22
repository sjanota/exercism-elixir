defmodule Frequency do
  alias Frequency.TextServer
  alias Frequency.Worker

  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, workers) do
    {:ok, texts_server} = TextServer.start(texts)

    workers = for _ <- 1..workers, do: Worker.start(self(), texts_server)

    merged = List.foldl(workers, %{}, &merge_in_result_from_worker/2)

    :ok = TextServer.stop(texts_server)
    merged
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

  def merge_in_result_from_worker(worker, acc) do
    receive do
      {^worker, counters} -> merge(acc, counters)
    end
  end

  defmodule TextServer do
    def start(texts) do
      Agent.start_link(fn ->
        for t <- texts do
          String.downcase(t)
        end
      end)
    end

    def stop(server) do
      Agent.stop(server)
    end

    def next_char(server) do
      Agent.get_and_update(server, &get_next_char/1)
    end

    defp get_next_char([]), do: {nil, []}
    defp get_next_char(["" | t]), do: get_next_char(t)

    defp get_next_char([text | t]) do
      {c, rest} = String.split_at(text, 1)
      {c, [rest | t]}
    end
  end

  defmodule Worker do
    def start(root, server) do
      spawn(fn -> process_loop(root, server, %{}) end)
    end

    defp process_loop(root, server, counters) do
      rsp = TextServer.next_char(server)

      case rsp do
        nil ->
          send(root, {self(), counters})

        c ->
          if String.match?(c, ~r/^\p{L}$/u) do
            count = Map.get(counters, c, 0)
            counters = Map.put(counters, c, count + 1)
            process_loop(root, server, counters)
          else
            process_loop(root, server, counters)
          end
      end
    end
  end
end
