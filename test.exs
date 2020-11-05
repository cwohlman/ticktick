defmodule PerformanceTest do
  def loop(count \\ 0) do
    {:ok, socket} = :gen_tcp.connect('localhost', 4000, [:binary, active: false])

    {:ok, data} = :gen_tcp.recv(socket, 0)

    IO.puts("#{data} - #{count}")

    loop(count + 1)
  end
end
