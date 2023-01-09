defmodule VintageHeart.MixProject do
  use Mix.Project

  def project do
    [
      app: :vintage_heart,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {VintageHeart.Application, []}
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
