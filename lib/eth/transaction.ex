require IEx

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
      to: to, value: value, data: data, gas_price: gas_price, gas_limit: gas_limit, nonce: nonce
    ]
    # |> Enum.map(fn(x) ->
    #   {key, value} = x
    #   {key, Base.encode16(value, case: :lower)}
    # end)
    |> Enum.into(%{chain_id: chain_id}) # NOTE: this is probably wrong
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
  }) do
    transaction
    |> Map.merge(%{v: encode16(<<chain_id>>), r: <<>>, s: <<>>})
    |> to_list
    |> Enum.map(fn(x) -> Base.decode16!(x, case: :mixed) end)
    |> hash
  end

  def hash(transaction_list, include_signature \\ true) do
    target_list = case include_signature do
      true -> transaction_list
      false ->
        # EIP155 spec:
        # when computing the hash of a transaction for purposes of signing or recovering,
        # instead of hashing only the first six elements (ie. nonce, gasprice, startgas, to, value, data),
        # hash nine elements, with v replaced by CHAIN_ID, r = 0 and s = 0
        list = transaction_list |> Enum.take(6)
        v = transaction_list |> Enum.at(6)
        chain_id = get_chain_id(v)
        if chain_id > 0, do: list ++ ["0x#{chain_id}", "0x", "0x"], else: list # NOTE: this part is dangerous: in JS we change state(v: chainId, r: 0, s: 0)
    end
    IO.puts("target_list is:")
    IO.inspect(target_list)

    target_list
    |> Enum.map(fn(value) -> # NOTE: maybe move this should be moved somewhere else (probably .set() sets these or transaction list)
      cond do
        is_number(value) ->
          IO.puts("value is")
          IO.puts(value)
          string_value = to_string(value)
          result = add_0_for_uneven_encoding(string_value)
          IO.puts("result is:")
          IO.puts(result)
          result
        String.slice(value, 0..1) == "0x" ->
          "0x" <> stripped_value = value
          encoded_value = add_0_for_uneven_encoding(stripped_value)
          Base.decode16!(encoded_value, case: :mixed)
        true -> value
      end
      # NOTE: else if (v === null || v === undefined) { v = Buffer.allocUnsafe(0) }
    end)
    |> ExRLP.encode
    |> keccak256
  end

  def verify_signature(transaction) do

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

  defp adjust_v_for_chain_id(transaction = %{ # NOTE: this is probably not correct
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

    [nonce, gas_price, gas_limit, to, value, data, v, r, s] # NOTE: maybe this should turn things toBuffer
  end

  def decode_transaction_list(transaction_list=[]) do
    # encoded_list = transaction_list # NOTE: remove this line
    # encoded_list = transaction_list |> Enum.map(fn(value) -> buffer_decoder(value) end)

    params = %{
      nonce: Enum.at(encoded_list, 0),
      gas_price: Enum.at(encoded_list, 1),
      gas_limit: Enum.at(encoded_list, 2),
      to: Enum.at(encoded_list, 3),
      value: Enum.at(encoded_list, 4),
      data: Enum.at(encoded_list, 5)
    }

    if transaction_list |> length > 6 do
      params |> Map.merge(%{
        v: Enum.at(encoded_list, 6),
        r: Enum.at(encoded_list, 7),
        s: Enum.at(encoded_list, 8)
      })
    else
      params
    end
  end

  def to_hex(value), do: HexPrefix.encode(value)

  defp add_0_for_uneven_encoding(value) do
    case rem(String.length(value), 2) == 1 do
      true -> "0" <> value
      false -> value
    end
  end

  defp get_chain_id(v) do
    "0x" <> v_string = v
    {sig_v, _} = Integer.parse(v_string, 16)
    chain_id = Float.floor((sig_v - 35) / 2)
    if chain_id < 0, do: 0, else: Kernel.trunc(chain_id)
  end

  defp buffer_to_int(data) do
    "0x" <> v_string = v
    {number, _} = Integer.parse(v_string, 16)
    number
  end

  defp buffer_encode(data) do
    "0x" <> Base.encode16(data, case: :mixed)
  end

  defp to_buffer(nil), do: ""
  defp to_buffer(data) when is_number(data), do: Hexate.encode(data)
  defp to_buffer("0x" <> data) do
    padded_data = pad_to_even(data)
    case Base.decode16(padded_data, case: :mixed) do
      {:ok, decoded_binary} -> decoded_binary
      _ -> data
    end
  end
  defp to_buffer(data), do: data

  defp pad_to_even(data) do
    if rem(String.length(data), 2) == 1 do
      "0#{data}"
    else
      data
    end
  end
end
