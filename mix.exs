defmodule Moonshine.MixProject do
  use Mix.Project
  @version "0.0.0-alpha-0"
  @github_path "joseph-lozano/moonshine"
  @url "https://github.com/#{@github_path}"

  def project do
    [
      name: "Moonshine",
      app: :moonshine,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      package: [
        description: "Static Blog Generator",
        licenses: ["MIT"],
        links: %{"GitHub" => @url}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end
