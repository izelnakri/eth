defmodule ETH.Utils do

  def get_private_key do
    :crypto.strong_rand_bytes(32)
  end

  def get_public_key(<< private_key :: binary-size(32) >>) do
    {public_key, ^private_key} = :crypto.generate_key(:ecdh, :secp256k1, private_key)
    public_key
  end
  def get_public_key(<< encoded_private_key :: binary-size(64) >>) do
    private_key = Base.decode16!(encoded_private_key, case: :mixed)
    {public_key, ^private_key} = :crypto.generate_key(:ecdh, :secp256k1, private_key)
    public_key
  end

  def get_address(<< private_key :: binary-size(32) >>) do
    public_key = private_key |> get_public_key()
    << _ :: binary-size(12), eth_address :: binary-size(20) >> = keccak256(public_key)
    "0x#{Base.encode16(eth_address)}"
  end
  def get_address(<< encoded_private_key :: binary-size(64) >>) do
    public_key = Base.decode16!(encoded_private_key, case: :mixed) |> get_public_key()
    << _ :: binary-size(12), eth_address :: binary-size(20) >> = keccak256(public_key)
    "0x#{Base.encode16(eth_address)}"
  end
  def get_address(<< public_key :: binary-size(65) >>) do
    << _ :: binary-size(12), eth_address :: binary-size(20) >> = keccak256(public_key)
    "0x#{Base.encode16(eth_address)}"
  end
  def get_address(<< encoded_public_key :: binary-size(130) >>) do
    public_key = Base.decode16!(encoded_public_key, case: :mixed)
    << _ :: binary-size(12), eth_address :: binary-size(20) >> = keccak256(public_key)
    "0x#{Base.encode16(eth_address)}"
  end

  def keccak256(data), do: :keccakf1600.hash(:sha3_256, data)
  defp encode16(value), do: Base.encode16(value, case: :lower)
end
