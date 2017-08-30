defmodule ETH.Query do
  def get_accounts do
    Ethereumex.HttpClient.eth_accounts
    |> elem(1)
    |> Map.get("result")
  end

  def get_balance(eth_address, denomination \\ :ether) do
    result = Ethereumex.HttpClient.eth_get_balance([eth_address])
    |> elem(1)
    |> Map.get("result")

    result
    |> String.slice(2..String.length(result))
    |> Hexate.to_integer
    |> ETH.convert(denomination)
  end
end
