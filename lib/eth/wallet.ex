defmodule ETH.Wallet do
  def create(private_key \\ :crypto.strong_rand_bytes(32)) do # pattern match on the base16 version as well
    {public_key, _} = :crypto.generate_key(:ecdh, :secp256k1, private_key)
    << 4 :: size(8), key :: binary-size(64) >> = public_key
    << _ :: binary-size(12), address :: binary-size(20) >> = keccak256(key)

    %{private_key: Base.encode16(private_key), public_key: Base.encode16(public_key),
      eth_address: "0x#{Base.encode16(address)}"}
  end

  # def get_public_key(<< private_key :: binary-size(32) >>) do
  #   {public_key, ^private_key} = :crypto.generate_key(:ecdh, :secp256k1, private_key)
  #   public_key
  # end
  #
  # def private_key_to_address(<< private_key :: binary-size(32) >>) do
  #   private_key
  #   |> get_public_key()
  #   |> public_key_to_address()
  # end
  #
  # def public_key_to_address(<< 4 :: size(8), key :: binary-size(64) >>) do
  #   << _ :: binary-size(12), address :: binary-size(20) >> = keccak256(key)
  #   address
  # end

  def balance do
    # Ethereumex
  end

  defp keccak256(data), do: :keccakf1600.hash(:sha3_256, data)
end
