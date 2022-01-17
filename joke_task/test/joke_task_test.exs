defmodule JokeTaskTest do
  use ExUnit.Case
  doctest JokeTask

  test "greets the world" do
    assert JokeTask.hello() == :world
  end
end
