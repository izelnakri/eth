# NOTE: maybe do HD Wallets + create(mnemonic phrase) + ICAP
defmodule ETH.Wallet do
  import ETH.Utils

  def create(private_key \\ :crypto.strong_rand_bytes(32))

  def create(<<encoded_private_key::binary-size(64)>>) do
    eth_address = encoded_private_key
      |> get_public_key()
      |> get_address()

    %{
      private_key: encoded_private_key,
      public_key: Base.encode16(get_public_key(encoded_private_key)),
      eth_address: eth_address,
      mnemonic_phrase: Mnemonic.entropy_to_mnemonic(encoded_private_key)
    }
  end

  def create(private_key) do
    encoded_private_key = Base.encode16(private_key)
    public_key = get_public_key(private_key)
    eth_address = get_address(public_key)

    %{
      private_key: encoded_private_key,
      public_key: Base.encode16(public_key),
      eth_address: eth_address,
      mnemonic_phrase: Mnemonic.entropy_to_mnemonic(encoded_private_key)
    }
  end

  def parse(private_key), do: create(private_key)
end
