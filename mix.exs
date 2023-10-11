defmodule AshSanity.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_sanity,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  if Mix.env() == :test do
    def application() do
      [
        applications: [:ash],
        mod: {AshSanity.TestApp, []}
      ]
    end
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ash, "~> 2.15"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:sanity, "~> 1.3"},
      {:mox, "~> 1.1", only: :test}
    ]
  end
end
