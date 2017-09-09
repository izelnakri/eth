defmodule ETH.Transaction do
  import ETH.Utils

  alias ETH.Query

  defdelegate set(params), to: ETH.Transaction.Setter
  defdelegate set(wallet, params), to: ETH.Transaction.Setter
  defdelegate set(sender_wallet, receiver_wallet, params), to: ETH.Transaction.Setter
  defdelegate parse(data), to: ETH.Transaction.Parser # NOTE: improve this one
  defdelegate to_list(data), to: ETH.Transaction.Parser
  defdelegate hash_transaction(transaction), to: ETH.Transaction.Signer
  defdelegate hash_transaction(transaction, include_signature), to: ETH.Transaction.Signer
  defdelegate hash_transaction_list(transaction_list), to: ETH.Transaction.Signer
  defdelegate hash_transaction_list(transaction_list, include_signature), to: ETH.Transaction.Signer
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

  def send_transaction(wallet, params) when is_map(params) do
    params
    |> Map.merge(%{from: wallet.eth_address})
    |> to_transaction(wallet.private_key)
  end
  def send_transaction(params, private_key) when is_list(params) do
    params
    |> to_transaction(private_key)
  end
  def send_transaction(params, private_key) when is_map(params) do
    params
    |> to_transaction(private_key)
  end
  def send_transaction(sender_wallet, receiver_wallet, value) when is_number(value) do
    %{from: sender_wallet.eth_address, to: receiver_wallet.eth_address, value: value}
    |> to_transaction(sender_wallet.private_key)
  end
  def send_transaction(sender_wallet, receiver_wallet, params) when is_map(params) do
    params
    |> Map.merge(%{from: sender_wallet.eth_address, to: receiver_wallet.eth_address})
    |> to_transaction(sender_wallet.private_key)
  end
  def send_transaction(sender_wallet, receiver_wallet, params) when is_list(params) do
    params
    |> Keyword.merge([from: sender_wallet.eth_address, to: receiver_wallet.eth_address])
    |> to_transaction(sender_wallet.private_key)
  end
  def send_transaction(sender_wallet, receiver_wallet, value, private_key) when is_number(value) do
    %{from: sender_wallet.eth_address, to: receiver_wallet.eth_address, value: value}
    |> to_transaction(private_key)
  end
  def send_transaction(sender_wallet, receiver_wallet, params, private_key) when is_map(params) do
    params
    |> Map.merge(%{from: sender_wallet.eth_address, to: receiver_wallet.eth_address})
    |> to_transaction(private_key)
  end
  def send_transaction(sender_wallet, receiver_wallet, params, private_key) when is_list(params) do
    params
    |> Keyword.merge([from: sender_wallet.eth_address, to: receiver_wallet.eth_address])
    |> to_transaction(private_key)
  end

  def send(signature), do: Ethereumex.HttpClient.eth_send_raw_transaction([signature])

  def get_senders_public_key("0x" <> rlp_encoded_transaction_list) do # NOTE: not tested
    rlp_encoded_transaction_list
    |> ExRLP.decode
    |> to_senders_public_key
  end
  def get_senders_public_key(<<encoded_tx>>) do
    encoded_tx
    |> Base.decode(case: :mixed)
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
  def get_sender_address(<<encoded_tx>>) do
    encoded_tx
    |> Base.decode(case: :mixed)
    |> ExRLP.decode
    |> to_senders_public_key
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

  defp to_transaction(params, private_key) do
    result = params
      |> set
      |> sign_transaction(private_key)
      |> Base.encode16
      |> send

    case result do
      {:ok, transaction_details} -> transaction_details["result"]
      _ -> result
    end
  end
end
