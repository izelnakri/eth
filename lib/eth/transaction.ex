require IEx

defmodule ETH.Transaction do
  import ETH.Utils

  alias ETH.Query

  def parse("0x" <> encoded_transaction_rlp) do
    encoded_transaction_rlp |> Base.decode16!(case: :mixed) |> ExRLP.decode
  end
  def parse(<<transaction_rlp>>), do: transaction_rlp |> ExRLP.decode
  def parse([nonce, gas_price, gas_limit, to, value, data]) do
    %{
      nonce: to_buffer(nonce), gas_price: to_buffer(gas_price), gas_limit: to_buffer(gas_limit),
      to: to_buffer(to), value: to_buffer(to), data: to_buffer(data)
    }
  end
  def parse([nonce, gas_price, gas_limit, to, value, data, v, r, s]) do
    %{
      nonce: to_buffer(nonce), gas_price: to_buffer(gas_price), gas_limit: to_buffer(gas_limit),
      to: to_buffer(to), value: to_buffer(to), data: to_buffer(data), v: to_buffer(v),
      r: to_buffer(r), s: to_buffer(s)
    }
  end
  def parse(%{
    nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: to, data: data
  }) do
    %{
      nonce: to_buffer(nonce), gas_price: to_buffer(gas_price), gas_limit: to_buffer(gas_limit),
      to: to_buffer(to), value: to_buffer(to), data: to_buffer(data)
    }
  end
  def parse(%{
    nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: to, data: data,
    v: v, r: r, s: s
  }) do
    %{
      nonce: to_buffer(nonce), gas_price: to_buffer(gas_price), gas_limit: to_buffer(gas_limit),
      to: to_buffer(to), value: to_buffer(to), data: to_buffer(data), v: to_buffer(v),
      r: to_buffer(r), s: to_buffer(s)
    }
  end

  def buffer_to_map(_transaction_buffer = [nonce, gas_price, gas_limit, to, value, data, v, r, s]) do
    %{
      nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data,
      v: v, r: r, s: s
    }
  end

  # def parse(params) do
  #   # add default values
  # end


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
    |> Enum.map(fn(x) ->
      {key, value} = x
      {key, to_buffer(value)}
    end)
    |> Enum.into(%{})
  end

  def sign(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce
  }, << private_key :: binary-size(32) >>), do: sign_transaction(transaction, private_key)
  def sign(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce
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
    nonce: _nonce
  }) do
    chain_id = Map.get(transaction, :chain_id, 0)
    transaction
    |> Map.merge(%{v: encode16(<<chain_id>>), r: <<>>, s: <<>>})
    |> to_list
    |> Enum.map(fn(x) ->
      # IEx.pry
      Base.decode16!(x, case: :mixed)
    end)
    |> hash
  end

  def hash(transaction_list, include_signature \\ true) do # NOTE: use internally
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
        if chain_id > 0, do: list ++ [chain_id, "", ""], else: list # NOTE: this part is dangerous: in JS we change state(v: chainId, r: 0, s: 0)
    end

    target_list
    |> Enum.map(fn(value) -> to_buffer(value) end)
    |> ExRLP.encode
    |> keccak256
  end

  defp sign_transaction(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce
  }, << private_key :: binary-size(32) >>) do
    hash = hash_transaction(transaction)
    IO.puts("hash is")
    # IO.puts(hash)
    [signature: signature, recovery: recovery] = secp256k1_signature(hash, private_key)

    << r :: binary-size(32) >> <> << s :: binary-size(32) >> = signature

    transaction
    |> Map.merge(%{r: encode16(r), s: encode16(s), v: encode16(<<recovery + 27>>)})
    |> adjust_v_for_chain_id
    |> to_list
    |> Enum.map(fn(x) ->
      # IEx.pry
      Base.decode16!(x, case: :mixed)
    end)
    |> ExRLP.encode
  end

  defp adjust_v_for_chain_id(transaction = %{ # NOTE: this is probably not correct
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, v: v, r: r, s: s
  }) do
    chain_id = Map.get(transaction, :chain_id, 0)
    if chain_id > 0 do
      current_v_bytes = Base.decode16!(v, case: :mixed) |> :binary.decode_unsigned
      target_v_bytes = current_v_bytes + (chain_id * 2 + 8)
      transaction |> Map.merge(%{v: encode16(<< target_v_bytes >>)})
    else
      transaction
    end
  end

  def to_list(transaction = %{
    nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data
  }) do
    v = Map.get(transaction, :v, Base.encode16(<<28>>, case: :lower)) # this probably needs to change
    r = Map.get(transaction, :r, "")
    s = Map.get(transaction, :s, "")

    [nonce, gas_price, gas_limit, to, value, data, v, r, s] # NOTE: maybe this should turn things toBuffer
    |> Enum.map(fn(value) -> to_buffer(value) end)
  end

  # def decode_transaction_list(transaction_list) when is_list(transaction_list) do
  #   encoded_list = transaction_list |> Enum.map(fn(value) -> Base.encode16(buffer_decoder(value)) end)
  #
  #   params = %{
  #     nonce: Enum.at(encoded_list, 0),
  #     gas_price: Enum.at(encoded_list, 1),
  #     gas_limit: Enum.at(encoded_list, 2),
  #     to: Enum.at(encoded_list, 3),
  #     value: Enum.at(encoded_list, 4),
  #     data: Enum.at(encoded_list, 5)
  #   }
  #
  #   if transaction_list |> length > 6 do
  #     params |> Map.merge(%{
  #       v: Enum.at(encoded_list, 6),
  #       r: Enum.at(encoded_list, 7),
  #       s: Enum.at(encoded_list, 8)
  #     })
  #   else
  #     params
  #   end
  # end

  def to_hex(value), do: HexPrefix.encode(value)
  # def to_json() # transaction_map or transaction_list

  defp get_chain_id("0x" <> v) do
    sig_v = buffer_to_int(v)
    chain_id = Float.floor((sig_v - 35) / 2)
    if chain_id < 0, do: 0, else: Kernel.trunc(chain_id)
  end
  defp get_chain_id(v) do
    sig_v = buffer_to_int(v)
    chain_id = Float.floor((sig_v - 35) / 2)
    if chain_id < 0, do: 0, else: Kernel.trunc(chain_id)
  end

  # defp buffer_to_int(""), do: 0
  defp buffer_to_int(data) do
    {number, _} = Integer.parse(data, 16)
    number
  end

  # defp buffer_decoder("0x"), do: ""
  # defp buffer_decoder("0x" <> data), do: Base.decode16!(data, case: :mixed)

  defp buffer_to_json_value(data) do
    "0x" <> Base.encode16(data, case: :mixed)
  end

  defp to_buffer(nil), do: ""
  defp to_buffer(data) when is_number(data) do
    IO.puts("NUMBER CALLED")
    IEx.pry
    pad_to_even(Hexate.encode(data)) |> Base.decode16!(case: :mixed)
  end
  defp to_buffer("0x" <> data) do
    padded_data = pad_to_even(data)
    case Base.decode16(padded_data, case: :mixed) do
      {:ok, decoded_binary} -> decoded_binary
      _ -> data
    end
  end
  defp to_buffer(data), do: data # NOTE: to_buffer else if (v === null || v === undefined) { v = Buffer.allocUnsafe(0) }

  def pad_to_even(data) do
    if rem(String.length(data), 2) == 1, do: "0#{data}", else: data
  end

  # def verify_signature(transaction) do
  # end
end





# def get_sender_address(signature) do
#   transaction_list = signature
#   |> ExRLP.decode
#   |> Enum.map(fn(value) -> "0x" <> Base.encode16(value) end)
#
#   v = transaction_list |> Enum.at(6) |> String.slice(2..-1) |> Hexate.to_integer
#   r = transaction_list |> Enum.at(7) |> String.slice(2..-1)
#   s = transaction_list |> Enum.at(8) |> String.slice(2..-1)
#
#   message_hash = hash(transaction_list, false)
#   signature = r <> s
#   recovery_id = v - 27
#
#   {:ok, public_key} = :libsecp256k1.ecdsa_recover_compact(message_hash, signature, :uncompressed, recovery_id)
#
#   get_address(public_key)
# end
