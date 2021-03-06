defmodule TickTickServer do
  require Logger

  def accept(port, counter) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket, counter)
  end

  defp loop_acceptor(socket, counter) do
    {:ok, client} = :gen_tcp.accept(socket)
    serve(client, counter)
    loop_acceptor(socket, counter)
  end

  defp serve(socket, counter) do
    write_line(socket, counter)

    :gen_tcp.shutdown(socket, :write)
  end

  defp write_line(socket, counter) do
    next = counter.()
    :gen_tcp.send(socket, "#{next}")
  end
end
