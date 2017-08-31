require IEx
defmodule ETH.Transaction do
  import ETH.Utils

  alias ETH.Query

  def set(params = [from: from, to: to, value: value]) do
    gas_price = Keyword.get(params, :gas_price, ETH.Query.gas_price())
    gas_limit = Keyword.get(params, :gas_limit, ETH.Query.gas_limit())
    data = Keyword.get(params, :data, "")
    nonce = Keyword.get(params, :nonce, ETH.Query.transaction_count(from))
    chain_id = Keyword.get(params, :chain_id, 3)

    %{
      from: from, to: to, value: value, gas_price: gas_price, gas_limit: gas_limit,
      data: data, nonce: nonce, chain_id: chain_id
    }
  end

  def sign(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, chain_id: _chain_id
  }, << private_key :: binary-size(32) >>), do: sign_transaction(transaction, private_key)
  def sign(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, chain_id: _chain_id
  }, << encoded_private_key :: binary-size(64) >>) do
    decoded_private_key = Base.decode16!(encoded_private_key, case: :lower)
    sign_transaction(transaction, decoded_private_key)
  end

  def send(signature) do
    # NOTE: make it strict
    Ethereumex.HttpClient.eth_send_raw_transaction([signature])
  end

  # def send(transaction \\ %{data: "", chain_id: 3, gas_price: 1})
  # NOTE: send_transaction\1
  # if there is a gas price dont use it
  # def send(transaction = %{from: from, to: to, value: value}) do
  #   transaction_params = case Map.get(transaction, :data) do
  #     nil -> transaction |> Map.merge(%{data: ""})
  #     _ -> transaction
  #   end
  #
  #   gas_limit = Map.get(transaction, :gas_limit, Query.estimate_gas(transaction_params)) # NOTE: maybe do it slightly more
  #
  #   IEx.pry
  #
  #   transaction_options = [
  #     data: Map.get(transaction, :data, ""), chain_id: Map.get(transaction, :chain_id, 3),
  #     gas_price: Map.get(transaction, :gas_price, 1), gas_limit: gas_limit
  #   ]
  #   # NOTE: get nonce
  #
  #   IEx.pry
  #   signature = ETH.sign_transaction(from, value, to, transaction_options)
  #   IEx.pry
  #   Ethereumex.HttpClient.eth_send_raw_transaction([signature])
  # end

  # set -> sign -> sign_transaction

  # def sign_transaction(
  #   source_eth_address, value, target_eth_address,
  #   options \\ [gas_price: 100, gas_limit: 1000, data: "", chain_id: 3]
  # ) do
  #   gas_price = options[:gas_price] |> Hexate.encode
  #   gas_limit = options[:gas_limit] |> Hexate.encode
  #   data = options[:data] |> Hexate.encode
  #
  #   nonce = case options[:nonce] do
  #     nil -> ETH.Query.get_transaction_count(source_eth_address)
  #     _ -> options[:nonce]
  #   end
  #
  #   # NOTE: calc nonce
  #   %{
  #     to: target_eth_address, value: Hexate.encode(value), gas_price: gas_price,
  #     gas_limit: gas_limit, data: data, chain_id: 3
  #   }
  #   # get nonce and make a transaction map -> sign_transaction -> send it to client
  # end

  def hash_transaction(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce, chain_id: _chain_id
  }) do
    # NOTE: if transaction is decoded no need to encode
    # EIP155 spec:
    # when computing the hash of a transaction for purposes of signing or recovering,
    # instead of hashing only the first six elements (ie. nonce, gasprice, startgas, to, value, data),
    # hash nine elements, with v replaced by CHAIN_ID, r = 0 and s = 0
    transaction
    |> Map.merge(%{v: encode16(<<transaction.chain_id>>), r: <<>>, s: <<>>})
    |> to_list
    |> Enum.map(fn(x) -> Base.decode16!(x, case: :lower) end)
    |> hash
  end

  def hash(transaction_list) do
    transaction_list
    |> ExRLP.encode
    |> keccak256
  end

  defp adjust_v_for_chain_id(transaction) do
    if transaction.chain_id > 0 do
      current_v_bytes = Base.decode16!(transaction.v, case: :lower) |> :binary.decode_unsigned
      target_v_bytes = current_v_bytes + (transaction.chain_id * 2 + 8)
      transaction |> Map.merge(%{v: encode16(<< target_v_bytes >>) })
    else
      transaction
    end
  end

  defp to_list(transaction) do
    %{
      nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data
    } = transaction

    v = Map.get(transaction, :v, Base.encode16(<<28>>, case: :lower))
    r = Map.get(transaction, :r, "")
    s = Map.get(transaction, :s, "")
    [nonce, gas_price, gas_limit, to, value, data, v, r, s]
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
    |> Enum.map(fn(x) -> Base.decode16!(x, case: :lower) end)
    |> ExRLP.encode
  end
end
