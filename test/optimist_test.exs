defmodule OptimistTest do
  use ExUnit.Case
  doctest Optimist

  test "greets the world" do
    assert Optimist.hello() == :world
  end
end
