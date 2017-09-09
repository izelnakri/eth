defmodule ETH.Wallet do
  import ETH.Utils

  def create(private_key \\ :crypto.strong_rand_bytes(32))
  def create(<< encoded_private_key :: binary-size(64) >>) do
    public_key = get_public_key(encoded_private_key)
    eth_address = get_address(public_key)

    %{private_key: encoded_private_key, public_key: Base.encode16(public_key),
      eth_address: eth_address}
  end
  def create(private_key) do
    public_key = get_public_key(private_key)
    eth_address = get_address(public_key)

    %{private_key: Base.encode16(private_key), public_key: Base.encode16(public_key),
      eth_address: eth_address}
  end

  def parse(private_key), do: create(private_key)
end
