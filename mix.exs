defmodule Eth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eth,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: description()
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
      {:libsecp256k1, [github: "mbrix/libsecp256k1", manager: :rebar]},
      {:keccakf1600, git: "https://github.com/jur0/erlang-keccakf1600", branch: "original-keccak"},
      {:ex_rlp, "~> 0.2.1"},
      {:hexate, "~> 0.6.1"},
      {:ethereumex, "~> 0.1.0"}
    ]
  end

  defp description do
     """
     Ethereum utilities for Elixir.
     """
  end

  def package do
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
