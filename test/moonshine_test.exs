defmodule MoonshineTest do
  use ExUnit.Case
  doctest Moonshine

  test "greets the world" do
    assert Moonshine.hello() == :world
  end
end
