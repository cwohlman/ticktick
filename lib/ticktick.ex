defmodule TickTick do
  def start_link do
    monotonic_offset = getMonotonicOffset()
    {:ok, pid} = Task.start_link(fn -> loop(getNextTickValue(monotonic_offset)) end)
    {:ok, _} = Task.start_link(fn -> tick(pid, monotonic_offset) end)
    fn ->
      send(pid, {:next, self()})
      receive do
        count -> count
      end
    end
  end

  defp loop(count) do
    receive do
      {:tick, newCount} ->
        # If we somehow exceed 100 million requests in one second, don't
        # allow the tick process to move us backwards
        loop(max(count, newCount))
      {:next, caller} ->
        send caller, count + 1
        loop(count + 1)
    end
  end

  defp tick(pid, monotonic_offset) do
    :timer.sleep(1000)
    send(pid, {:tick, getNextTickValue(monotonic_offset)})
    tick(pid, monotonic_offset)
  end

  defp getNextTickValue(monotonic_offset) do
    # Linux tops out at ~1 million packets per second, apparently (see https://blog.cloudflare.com/how-to-receive-a-million-packets/)
    # Also this gives us a 100 million unique ids for every second between the unix epoch and the year ~5000
    max_packets_per_second = 100_000_000

    # TODO: We can support multiple servers by splitting the 100 million id space 2-10 ways
    # e.g. giving one server 0-10 million, the next 10-20 million, etc.
    # this would require guarding against overflows

    getMonotonicUnixTime(monotonic_offset) * max_packets_per_second
  end

  defp getMonotonicUnixTime(monotonic_offset) do
    System.monotonic_time(:second) + monotonic_offset
  end

  defp getMonotonicOffset do
    {:ok, date} = DateTime.now("Etc/UTC")
    monotonic_time = System.monotonic_time(:second)
    unix_seconds = DateTime.to_unix(date, :second)

    # If unix seconds is the larger value, this result will be positive
    # If monotonic time is the larger value, this result will be negative
    unix_seconds - monotonic_time
  end
end
