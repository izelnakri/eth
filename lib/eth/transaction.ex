require IEx
# TODO :probably I have to do hexate encodings
defmodule ETH.Transaction do
  import ETH.Utils

  alias ETH.Query

  def set(params = [from: from, to: to, value: value]) do
    gas_price = Keyword.get(params, :gas_price, ETH.Query.gas_price())
    data = Keyword.get(params, :data, "")
    nonce = Keyword.get(params, :nonce, ETH.Query.get_transaction_count(from))
    chain_id = Keyword.get(params, :chain_id, 3)
    gas_limit = Keyword.get(params, :gas_limit, ETH.Query.estimate_gas(%{
      to: to, value: value, data: data, nonce: nonce, chain_id: chain_id
    }))

    [
      to: to, value: to_hex(value), data: to_hex(data), gas_price: to_hex(gas_price),
      gas_limit: to_hex(gas_limit), nonce: nonce
    ] |> Enum.map(fn(x) ->
      {key, value} = x
      {key, Base.encode16(value, case: :lower)}
    end) |> Enum.into(%{chain_id: chain_id})
  end

  def sign(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, chain_id: _chain_id
  }, << private_key :: binary-size(32) >>), do: sign_transaction(transaction, private_key)
  def sign(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, chain_id: _chain_id
  }, << encoded_private_key :: binary-size(64) >>) do
    decoded_private_key = Base.decode16!(encoded_private_key, case: :mixed)
    sign_transaction(transaction, decoded_private_key)
  end

  def send(signature), do: Ethereumex.HttpClient.eth_send_raw_transaction([signature])

  def send_transaction(params = [from: _from, to: _to, value: _value], private_key) do
    set(params)
    |> sign(private_key)
    |> send
  end
  def send_transaction(params = %{from: _from, to: _to, value: _value}, private_key) do
    Map.to_list(params)
    |> set
    |> sign(private_key)
    |> send
  end

  # NOTE: if transaction is decoded no need to encode

  def hash_transaction(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, chain_id: chain_id
  }) do # EIP155 spec:
    # when computing the hash of a transaction for purposes of signing or recovering,
    # instead of hashing only the first six elements (ie. nonce, gasprice, startgas, to, value, data),
    # hash nine elements, with v replaced by CHAIN_ID, r = 0 and s = 0
    transaction
    |> Map.merge(%{v: encode16(<<chain_id>>), r: <<>>, s: <<>>})
    |> to_list
    |> Enum.map(fn(x) -> Base.decode16!(x, case: :mixed) end)
    |> hash
  end

  def hash(transaction_list = [_nonce, _gas_price, _gas_limit, _to, _value, _data, _v, _r, _s]) do
    transaction_list
    |> ExRLP.encode
    |> keccak256
  end

  defp sign_transaction(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, chain_id: _chain_id
  }, << private_key :: binary-size(32) >>) do
    hash = hash_transaction(transaction)
    [signature: signature, recovery: recovery] = secp256k1_signature(hash, private_key)

    << r :: binary-size(32) >> <> << s :: binary-size(32) >> = signature

    transaction
    |> Map.merge(%{r: encode16(r), s: encode16(s), v: encode16(<<recovery + 27>>)})
    |> adjust_v_for_chain_id
    |> to_list
    |> Enum.map(fn(x) -> Base.decode16!(x, case: :mixed) end)
    |> ExRLP.encode
  end

  defp adjust_v_for_chain_id(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, chain_id: chain_id, v: v, r: r, s: s
  }) do
    if chain_id > 0 do
      current_v_bytes = Base.decode16!(v, case: :mixed) |> :binary.decode_unsigned
      target_v_bytes = current_v_bytes + (chain_id * 2 + 8)
      transaction |> Map.merge(%{v: encode16(<< target_v_bytes >>)})
    else
      transaction
    end
  end

  defp to_list(transaction = %{
    nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data
  }) do
    v = Map.get(transaction, :v, Base.encode16(<<28>>, case: :lower))
    r = Map.get(transaction, :r, "")
    s = Map.get(transaction, :s, "")
    [nonce, gas_price, gas_limit, to, value, data, v, r, s]
  end

  def to_hex(value), do: Hexate.encode(value)
end
