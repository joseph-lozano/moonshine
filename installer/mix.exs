defmodule Moonshine.New.MixProject do
  use Mix.Project

  @version "0.0.1-alpha-0"
  @github_path "joseph-lozano/moonshine"
  @url "https://github.com/#{@github_path}"

  def project do
    [
      app: :moonshine_new,
      start_permanent: Mix.env() == :prod,
      version: @version,
      elixir: "~> 1.12",
      deps: deps(),
      package: [
        maintainers: [
          "Joseph Lozano"
        ],
        licenses: ["MIT"],
        links: %{github: @url},
        files: ~w(lib templates mix.exs README.md)
      ],
      source_url: @url,
      # docs: docs(),
      homepage_url: "",
      description: """
      Moonshine Blog Generator
      Provides a `mix moonshine.new` task to bootstrap a new Elixir application
      with Moonshine dependencies.
      """
    ]
  end

  def application do
    [
      extra_applications: [:eex]
    ]
  end

  def deps do
    [
      {:ex_doc, "~> 0.23.0", only: :docs}
    ]
  end

  # defp docs do
  #   [
  #     source_url_pattern:
  #       "https://github.com/#{@github_path}/blob/v#{@version}/installer/%{path}#L%{line}"
  #   ]
  # end
end
