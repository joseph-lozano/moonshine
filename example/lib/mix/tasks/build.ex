defmodule Mix.Tasks.Moonshine.Build do
  @moduledoc false

  use Mix.Task

  def run(_args) do
    Moonshine.make()
  end
end
