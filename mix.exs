defmodule Eth.Mixfile do
  use Mix.Project

  @version "0.6.1"
  @source_url "https://github.com/izelnakri/eth"

  def project() do
    [
      app: :eth,
      version: @version,
      elixir: "~> 1.11",
      description: description(),
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger, :telemetry, :ethereumex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:ethereumex, "~> 0.7.0"},
      {:ex_rlp, "~> 0.5.3"},
      {:ex_doc, ">= 0.23.0", only: :dev},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:hexate, "~> 0.6.1"},
      {:ex_keccak, "~> 0.1.2"},
      {:mnemonic, "~> 0.3.0"},
      {:poison, "~> 4.0.1"},
      {:ex_secp256k1, "~> 0.1.2"},
      {:telemetry, "~> 0.4.2"}
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
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "Docs" => "https://hexdocs.pm/eth/ETH.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "README.md",
        "CHANGELOG.md"
      ]
    ]
  end
end
