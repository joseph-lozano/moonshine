defmodule Moonshine.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :moonshine,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_options: elixirc_options(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix, :eex]]
    ]
  end

  defp elixirc_options(:dev), do: []
  defp elixirc_options(_), do: [warnings_as_errors: true]

  def aliases() do
    [
      build: [
        "moonshine.build",
        "cmd npm run build"
      ],
      build_clean: [
        "cmd rm -rf _site",
        "build"
      ],
      server: [
        "cmd scripts/server.sh"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Moonshine.Application, []},
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:plug_cowboy, "~> 2.0", only: [:dev, :test]},
      {:file_system, "~> 0.2", only: [:dev, :test]},
      {:earmark, "~> 1.4"},
      {:yaml_elixir, "~> 2.6"},
      {:typed_struct, "~> 0.2.1"},
      {:makeup_elixir, "~> 0.15.1"}
    ]
  end
end
