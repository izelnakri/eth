require IEx
# elliptic curve cryptography library for Ethereum
defmodule ETH do
  @moduledoc """
  Documentation for Eth.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Eth.hello
      :world

  """

  def private_key_to_address(<< private_key :: binary-size(32) >>) do
    private_key
    |> private_key_to_public_key()
    |> public_key_to_address()
  end

  def private_key_to_public_key(<< private_key :: binary-size(32) >>) do
    {public_key, ^private_key} = :crypto.generate_key(:ecdh, :secp256k1, private_key)
    public_key
  end

  def public_key_to_address(<< 4 :: size(8), key :: binary-size(64) >>) do
    << _ :: binary-size(12), address :: binary-size(20) >> = keccak256(key)
    address
  end

  def sign_transaction(transaction, private_key) do # must have chain_id
    hash = hash_transaction(transaction)
    decoded_private_key = Base.decode16!(private_key, case: :lower)
    [signature: signature, recovery: recovery] = secp256k1_signature(hash, decoded_private_key)

    << r :: binary-size(32) >> <> << s :: binary-size(32) >> = signature

    transaction
    |> Map.merge(%{r: encode16(r), s: encode16(s), v: encode16(<<recovery + 27>>)})
    |> adjust_v_for_chain_id
    |> transaction_list
    |> Enum.map(fn(x) -> Base.decode16!(x, case: :lower) end)
    |> ExRLP.encode
  end

  def adjust_v_for_chain_id(transaction) do
    if transaction.chain_id > 0 do
      current_v_bytes = Base.decode16!(transaction.v, case: :lower) |> :binary.decode_unsigned
      transaction |> Map.merge(%{v: encode16(<< current_v_bytes + (transaction.chain_id * 2 + 8) >>) })
    else
      transaction
    end
  end

  def secp256k1_signature(hash, private_key) do
    {:ok, signature, recovery} = :libsecp256k1.ecdsa_sign_compact(hash, private_key, :default, <<>>)
    [signature: signature, recovery: recovery]
  end

  # must have [nonce, gasPrice, gasLimit, to, value, data] # and chainId inside the transaction?
  def hash_transaction(transaction) do
    # EIP155 spec:
    # when computing the hash of a transaction for purposes of signing or recovering,
    # instead of hashing only the first six elements (ie. nonce, gasprice, startgas, to, value, data),
    # hash nine elements, with v replaced by CHAIN_ID, r = 0 and s = 0
    transaction |> Map.merge(%{v: encode16(<<transaction.chain_id>>), r: <<>>, s: <<>> })
    |> transaction_list
    |> Enum.map(fn(x) -> Base.decode16!(x, case: :lower) end)
    |> hash
  end

  def hash(transaction_list) do
    transaction_list
    |> ExRLP.encode
    |> keccak256
  end

  def transaction_list(transaction \\ %{}) do
    %{
      nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data
    } = transaction

    v = if Map.get(transaction, :v), do: transaction.v, else: Base.encode16(<<28>>, case: :lower)
    r = default_is_empty(transaction, :r)
    s = default_is_empty(transaction, :s)
    [nonce, gas_price, gas_limit, to, value, data, v, r, s]
  end

  def keccak256(data), do: :keccakf1600.hash(:sha3_256, data)
  defp encode16(value), do: Base.encode16(value, case: :lower)
  defp default_is_empty(map, key), do: if Map.get(map, key), do: Map.get(map, key), else: ""
end
