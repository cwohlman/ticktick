# Ticktick

I'm working on some code involving event sourcing, and thought: wouldn't it be cool if I had a server that could serve monotonically increasing ids. This is that server.

I'm new to elixir, and there are known bugs, so don't use this.

Currently returns a new id for every tcp connection.

To run: `mix run` and get ids by connecting to port 4000
