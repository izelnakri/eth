require IEx
defmodule ETH.Transaction do
  import ETH.Utils

  alias ETH.Query

  defdelegate parse(data), to: ETH.Transaction.Parser # NOTE: improve this one
  defdelegate to_list(data), to: ETH.Transaction.Parser
  defdelegate hash_transaction(transaction), to: ETH.Transaction.Signer
  defdelegate hash_transaction(transaction, include_signature), to: ETH.Transaction.Signer
  defdelegate hash_transaction_list(transaction_list), to: ETH.Transaction.Signer
  defdelegate hash_transaction_list(transaction_list, include_signature), to: ETH.Transaction.Signer
  # TODO: allow ETH.Transaction.Wallet for signing
  defdelegate sign_transaction(transaction, private_key), to: ETH.Transaction.Signer
  defdelegate sign_transaction_list(transaction_list, private_key), to: ETH.Transaction.Signer
  defdelegate decode(rlp_encoded_transaction), to: ETH.Transaction.Signer
  defdelegate encode(signed_transaction_list), to: ETH.Transaction.Signer

  def hash(transaction, include_signature \\ true)
  def hash(transaction, include_signature) when is_list(transaction) do
    ETH.Transaction.Signer.hash_transaction_list(transaction, include_signature)
  end
  def hash(transaction=%{}, include_signature) do
    ETH.Transaction.Signer.hash_transaction(transaction, include_signature)
  end

  # TODO: what if its a wallet
  def set(params = %{from: from, to: to, value: value}) do
    gas_price = Keyword.get(params, :gas_price, ETH.Query.gas_price())
    data = Keyword.get(params, :data, "")
    nonce = Keyword.get(params, :nonce, ETH.Query.get_transaction_count(from))
    chain_id = Keyword.get(params, :chain_id, 3)
    gas_limit = Keyword.get(params, :gas_limit, ETH.Query.estimate_gas(%{
      to: to, value: value, data: data, nonce: nonce, chain_id: chain_id
    }))

    %{nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data}
    |> parse
  end
  def set(params = [from: from, to: to, value: value]) do
    gas_price = Keyword.get(params, :gas_price, ETH.Query.gas_price())
    data = Keyword.get(params, :data, "")
    nonce = Keyword.get(params, :nonce, ETH.Query.get_transaction_count(from))
    chain_id = Keyword.get(params, :chain_id, 3)
    gas_limit = Keyword.get(params, :gas_limit, ETH.Query.estimate_gas(%{
      to: to, value: value, data: data, nonce: nonce, chain_id: chain_id
    }))

    %{nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data}
    |> parse
  end

  # TODO: what if its a wallet
  def send_transaction(params = %{from: _from, to: _to, value: _value}, private_key) do
    params
    |> set
    |> to_list
    |> sign_transaction_list(private_key)
    |> send
  end
  def send_transaction(params = [from: _from, to: _to, value: _value], private_key) do
    params
    |> set
    |> to_list
    |> sign_transaction_list(private_key)
    |> send
  end

  def send(signature), do: Ethereumex.HttpClient.eth_send_raw_transaction([signature])

  def get_senders_public_key("0x" <> rlp_encoded_transaction_list) do # NOTE: not tested
    rlp_encoded_transaction_list
    |> ExRLP.decode
    |> to_senders_public_key
  end
  def get_senders_public_key(transaction_list = [
    nonce, gas_price, gas_limit, to, value, data, v, r, s
  ]), do: to_senders_public_key(transaction_list)

  def get_sender_address("0x" <> rlp_encoded_transaction_list) do # NOTE: not tested
    rlp_encoded_transaction_list
    |> ExRLP.decode
    |> get_senders_public_key
    |> get_address
  end
  def get_sender_address(transaction_list = [
    nonce, gas_price, gas_limit, to, value, data, v, r, s
  ]), do: get_senders_public_key(transaction_list) |> get_address

  defp to_senders_public_key(transaction_list = [
    nonce, gas_price, gas_limit, to, value, data, v, r, s
  ]) do
    message_hash = hash_transaction_list(transaction_list, false)
    chain_id = get_chain_id(v, Enum.at(transaction_list, 9))
    v_int = buffer_to_int(v)
    target_v = if chain_id > 0, do: v_int - (chain_id * 2 + 8), else: v_int

    signature = r <> s
    recovery_id = target_v - 27

    {:ok, public_key} = :libsecp256k1.ecdsa_recover_compact(message_hash, signature, :uncompressed, recovery_id)
    public_key
  end
end
