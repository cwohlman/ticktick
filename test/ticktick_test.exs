defmodule TicktickTest do
  use ExUnit.Case
  doctest Ticktick

  test "greets the world" do
    assert Ticktick.hello() == :world
  end
end
