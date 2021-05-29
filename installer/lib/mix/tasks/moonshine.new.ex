defmodule Mix.Tasks.Moonshine.New do
  @moduledoc """
  TODO
  """

  use Mix.Task

  @version Mix.Project.config()[:version]
  @shortdoc "Creats a new Moonshine application"
  @before_compile Moonshine.TemplateGenerator
  Module.register_attribute(__MODULE__, :templates, accumulate: true)

  def run([version]) when version in ~w(-v --version) do
    Mix.shell().info("Moonshine v#{@version}")
  end

  def run(argv) do
    elixir_version_check!()
    path = path_check!(argv)
    generate(path)
  end

  defp generate(path) do
    full_path = Path.expand(path)

    File.mkdir!(full_path)
    copy_templates(full_path, Macro.camelize(path))
  end

  defp copy_templates(path, module) do
    # content =
    #   EEx.eval_file("./templates/blog.ex", namespace: module)
    @templates
    |> IO.inspect()

    # File.write!(Path.join(path, "blog.ex"), content, [:write])
  end

  defp path_check!([path]) do
    unless String.replace(path, ~r/[a-z]|_|\d/, "") do
      Mix.raise(
        "The supplied path can only contain underscores and lower-case letters.\n" <>
          "You gave: #{inspect(path)}"
      )
    end

    path
  end

  defp path_check!(argv) do
    Mix.raise(
      "You must provide exactly 1 argument to `mix moonshine.new`.\n" <>
        "Received: #{Enum.join(argv, " ")}"
    )
  end

  defp elixir_version_check! do
    unless Version.match?(System.version(), "~> 1.7") do
      Mix.raise(
        "Phoenix v#{@version} requires at least Elixir v1.7.\n " <>
          "You have #{System.version()}. Please update accordingly"
      )
    end
  end
end
