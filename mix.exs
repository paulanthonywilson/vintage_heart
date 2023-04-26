defmodule VintageHeart.MixProject do
  use Mix.Project

  def project do
    [
      app: :vintage_heart,
      version: "0.1.2",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      docs: docs()
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
      {:credo, "~> 1.6", only: [:dev, :test]},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29.1", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package() do
    [
      description:
        "For Nerves projects that need an Internet connection, monitors and gives VintageNet a kick and eventually causes a reboot if connectivity is lost",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/paulanthonywilson/vintage_heart/"}
    ]
  end

  defp docs do
    [main: "readme", extras: ["README.md", "CHANGELOG.md"]]
  end
end
