defmodule ETH.Utils do

  def get_private_key, do: :crypto.strong_rand_bytes(32)

  def get_public_key(<< private_key :: binary-size(32) >>) do
    {:ok, public_key} = :libsecp256k1.ec_pubkey_create(private_key, :uncompressed)
    public_key
  end
  def get_public_key(<< encoded_private_key :: binary-size(64) >>) do
    private_key = Base.decode16!(encoded_private_key, case: :mixed)
    {:ok, public_key} = :libsecp256k1.ec_pubkey_create(private_key, :uncompressed)
    public_key
  end

  def get_address(<< private_key :: binary-size(32) >>) do
    << 4 :: size(8), key :: binary-size(64) >> = private_key |> get_public_key()
    << _ :: binary-size(12), eth_address :: binary-size(20) >> = keccak256(key)
    "0x#{Base.encode16(eth_address)}"
  end
  def get_address(<< encoded_private_key :: binary-size(64) >>) do
    public_key = Base.decode16!(encoded_private_key) |> get_public_key()
    << 4 :: size(8), key :: binary-size(64) >> = public_key
    << _ :: binary-size(12), eth_address :: binary-size(20) >> = keccak256(key)
    "0x#{Base.encode16(eth_address)}"
  end
  def get_address(<< 4 :: size(8), key :: binary-size(64) >>) do
    << _ :: binary-size(12), eth_address :: binary-size(20) >> = keccak256(key)
    "0x#{Base.encode16(eth_address)}"
  end
  def get_address(<< encoded_public_key :: binary-size(130) >>) do
    << 4 :: size(8), key :: binary-size(64) >> = Base.decode16!(encoded_public_key)
    << _ :: binary-size(12), eth_address :: binary-size(20) >> = keccak256(key)
    "0x#{Base.encode16(eth_address)}"
  end

  # NOTE: not tested area:
  def convert(number, magnitute \\ :ether) do
    denomination = [
      wei:     1,
      kwei:    1000,
      mwei:    1000000,
      gwei:    1000000000,
      shannon: 1000000000,
      nano:    1000000000,
      szabo:   1000000000000,
      micro:   1000000000000,
      finney:  1000000000000000,
      milli:   1000000000000000,
      ether:   1000000000000000000,
    ] |> List.keyfind(magnitute, 0) |> elem(1)

    number / denomination
  end

  def secp256k1_signature(hash, private_key) do
    {:ok, signature, recovery} = :libsecp256k1.ecdsa_sign_compact(hash, private_key, :default, <<>>)
    [signature: signature, recovery: recovery]
  end

  def keccak256(data), do: :keccakf1600.hash(:sha3_256, data)
  def encode16(value), do: Base.encode16(value, case: :lower)
end

# NOTE: old version that is error-prone:
# {public_key, ^private_key} = :crypto.generate_key(:ecdh, :secp256k1, private_key)
