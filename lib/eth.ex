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

  def get_number(result, denomination \\ :ether) do
    result |> elem(1) |> Map.get("result") |> String.slice(2..-1) |> Hexate.to_integer
  end

  def sign_transaction(transaction, private_key) do
    hash = hash_transaction(transaction)
    [signature: signature, recovery_id: recovery_id] = secp256k1_signature(hash, private_key)

    # IEx.pry

    << r :: binary-size(32) >> <> << s :: binary-size(32) >> = signature

    IEx.pry

    # IO.puts("r hex is:")
    # IO.puts(r)
    # IO.puts("s hex is:")
    # IO.puts(s)

    transaction
    |> Map.merge(%{r: r, s: s, v: recovery_id + 27 })
    |> adjust_v_for_chain_id
    |> ExRLP.encode(encoding: :hex)

      #     const ret = {}
      # ret.r = sig.signature.slice(0, 32)
      # ret.s = sig.signature.slice(32, 64)
      # ret.v = sig.recovery + 27
      # return re # append to this.raw

      # then

      # if (this._chainId > 0) { # chainId 0 by default
      #   sig.v += this._chainId * 2 + 8
      # }


    # v '1c',
    # r '2b40675300e8c453ecda0e71af527b2f238bef018372f6b0d194bc5307e5ba05',
    # s '5872815809435f8e977bbd0d8ac6a65e96803a177506dd0dcfeefd17cb998da6' ]
  end

  def adjust_v_for_chain_id(transaction) do
    if transaction.chain_id > 0 do
      transaction |> Map.merge(%{ v: transaction.v + (transaction.chain_id * 2 + 8) })
    else
      transaction
    end
  end

  def secp256k1_signature(hash, private_key) do
    {:ok, signature, recovery_id} = :libsecp256k1.ecdsa_sign_compact(hash, private_key, :default, <<>>)
    [signature: signature, recovery_id: recovery_id]
  end

  # must have [nonce, gasPrice, gasLimit, to, value, data] # and chainId inside the transaction?
  def hash_transaction(transaction) do
    transaction |> Map.merge(%{v: transaction.chain_id, r: 0, s: 0}) # 0s here are problematic!
    |> transaction_list
    |> hash
  end

  def hash(transaction_list) do # NOTE: expects all values in base16
    # IEx.pry
    transaction_list
    |> Enum.map(fn(x) -> Base.decode16!(x, case: :lower) end) # this could be complicated for empty values
    |> ExRLP.encode
    |> keccak256
  end

  def keccak256(data), do: :keccakf1600.hash(:sha3_256, data)

  def transaction_list(transaction \\ %{}) do # [nonce, gasPrice, gasLimit, to, value, data, v(1c), r, s]
    %{
      nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data
    } = transaction

    [nonce, gas_price, gas_limit, to, value, data] |> append_signature(transaction)
  end

  defp append_signature(transaction_list, transaction) do
    append_to_list_if_exists(transaction_list, transaction, :v)
    |> append_to_list_if_exists(transaction, :r)
    |> append_to_list_if_exists(transaction, :s)
  end

  defp append_to_list_if_exists(transaction_list, transaction, key) do
    case Map.fetch(transaction, key) do
      :error -> transaction_list
      {:ok, nil} -> transaction_list
      {:ok, value} -> transaction_list ++ [value]
    end
  end

  # def hexate_encode(value), do: "0x#{Hexate.encode(value)}"
end
