require IEx
defmodule ETH.Transaction do
  # NOTE: add ExRLP.encode() / .serialize() to complete this
  import ETH.Utils

  alias ETH.Query

  defdelegate parse(data), to: ETH.Transaction.Parser
  defdelegate to_list(data), to: ETH.Transaction.Parser
  defdelegate sign_transaction_list(transaction_list, private_key), to: ETH.Transaction.Signer
  defdelegate hash(transaction_list), to: ETH.Transaction.Signer
  defdelegate hash(transaction_list, include_signature), to: ETH.Transaction.Signer

  # def set(params = [from: from, to: to, value: value]) do
  #   gas_price = Keyword.get(params, :gas_price, ETH.Query.gas_price())
  #   data = Keyword.get(params, :data, "")
  #   nonce = Keyword.get(params, :nonce, ETH.Query.get_transaction_count(from))
  #   chain_id = Keyword.get(params, :chain_id, 3)
  #   gas_limit = Keyword.get(params, :gas_limit, ETH.Query.estimate_gas(%{
  #     to: to, value: value, data: data, nonce: nonce, chain_id: chain_id
  #   }))
  #
  #   [
  #     to: to, value: value, data: data, gas_price: gas_price, gas_limit: gas_limit, nonce: nonce
  #   ]
  #   |> Enum.map(fn(x) ->
  #     {key, value} = x
  #     {key, to_buffer(value)}
  #   end)
  #   |> Enum.into(%{})
  # end
  # def sign_transaction(transaction=%{}) do
  #   transaction_list =
  # end

  def get_sender_address(transaction_list = [nonce, gas_price, gas_limit, to, value, data, v, r, s]) do
    message_hash = hash(transaction_list, false)
    chain_id = get_chain_id(v, Enum.at(transaction_list, 9))
    v_int = buffer_to_int(v)
    target_v = if chain_id > 0, do: v_int - (chain_id * 2 + 8), else: v_int

    signature = r <> s
    recovery_id = target_v - 27

    {:ok, public_key} = :libsecp256k1.ecdsa_recover_compact(message_hash, signature, :uncompressed, recovery_id)
    get_address(public_key)
  end

  # def sign_transaction_list(transaction = %{
  #   to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
  #   nonce: _nonce
  # }, << private_key :: binary-size(32) >>), do: sign_transaction(transaction, private_key)
  # def sign_transaction_list(transaction = %{
  #   to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
  #   nonce: _nonce
  # }, << encoded_private_key :: binary-size(64) >>) do
  #   decoded_private_key = Base.decode16!(encoded_private_key, case: :mixed)
  #   sign_transaction(transaction, decoded_private_key)
  # end

  def send(signature), do: Ethereumex.HttpClient.eth_send_raw_transaction([signature])

  # def send_transaction(params = [from: _from, to: _to, value: _value], private_key) do
  #   set(params)
  #   |> sign_transaction_list(private_key)
  #   |> send
  # end
  # def send_transaction(params = %{from: _from, to: _to, value: _value}, private_key) do
  #   Map.to_list(params)
  #   |> set
  #   |> sign_transaction_list(private_key)
  #   |> send
  # end

  def hash_transaction(transaction, include_signature \\ true)
  def hash_transaction(transaction = %{
    to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
    nonce: _nonce
  }, include_signature) do
    chain_id = get_chain_id(Map.get(transaction, :v, <<28>>), Map.get(transaction, :chain_id))

    transaction
    |> Map.delete(:chain_id)
    |> to_list
    |> List.insert_at(-1, chain_id)
    |> hash(include_signature)
  end
  def hash_transaction(transaction=%{}, include_signature) do
    chain_id = get_chain_id(Map.get(transaction, :v, <<28>>), Map.get(transaction, :chain_id))

    transaction
    |> Map.delete(:chain_id)
    |> to_list
    |> List.insert_at(-1, chain_id)
    |> hash(include_signature)
  end

  # defp sign_transaction(transaction = %{
  #   to: _to, value: _value, data: _data, gas_price: _gas_price, gas_limit: _gas_limit,
  #   nonce: _nonce
  # }, << private_key :: binary-size(32) >>) do
  #   hash = hash_transaction(transaction)
  #   IO.puts("hash is")
  #   IO.puts(hash)
  #   [signature: signature, recovery: recovery] = secp256k1_signature(hash, private_key)
  #
  #   << r :: binary-size(32) >> <> << s :: binary-size(32) >> = signature
  #
  #   # this will change v, r, s
  #   transaction
  #   # |> Map.merge(%{r: encode16(r), s: encode16(s), v: encode16(<<recovery + 27>>)})
  #   |> adjust_v_for_chain_id
  #   |> to_list
  #   |> Enum.map(fn(x) ->
  #     # IEx.pry
  #     Base.decode16!(x, case: :mixed)
  #   end)
  #   |> ExRLP.encode
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
