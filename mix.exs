defmodule AshSanity.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_sanity,
      version: "0.3.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/sbennett33/ash_sanity"
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
      {:mox, "~> 1.1", only: :test},
      {:ex_doc, "~> 0.31.2", only: :dev, runtime: false}
    ]
  end

  def description do
    """
    Ash DataLayer for the Sanity.io CMS
    """
  end

  def package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sbennett33/ash_sanity"}
    ]
  end
end
