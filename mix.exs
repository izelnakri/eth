defmodule Eth.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :eth,
      version: "0.4.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger, :telemetry, :ethereumex, :libsecp256k1]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:ethereumex, "~> 0.6.0"},
      {:ex_rlp, "~> 0.5.3"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false},
      {:hexate, "~> 0.6.1"},
      {:keccakf1600, "~> 2.0", hex: :keccakf1600_orig},
      {:mnemonic, "~> 0.2.1"},
      {:poison, "~> 4.0.1"},
      {:libsecp256k1, "~> 0.1.10"},
      {:telemetry, "~> 0.4"}
    ]
  end

  defp description() do
    """
    Ethereum utilities for Elixir.
    """
  end

  def package() do
    [
      name: :eth,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Izel Nakri"],
      licenses: ["MIT License"],
      links: %{
        "GitHub" => "https://github.com/izelnakri/eth",
        "Docs" => "https://hexdocs.pm/eth/ETH.html"
      }
    ]
  end
end
