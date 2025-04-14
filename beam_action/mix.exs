defmodule BeamAction.MixProject do
  use Mix.Project

  def project do
    [
      app: :beam_action,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "GitHub Actions YAML Runner in Elixir",
      package: package(),
      source_url: "https://github.com/samrose/beam-action",
      docs: [
        main: "readme",
        extras: ["README.md"]
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
      {:yaml_elixir, "~> 2.9"},
      {:erlexec, "~> 2.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "beam_action",
      files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["Your Name"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/yourusername/beam-action"}
    ]
  end
end
