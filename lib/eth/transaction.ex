defmodule ETH.Transaction do
  import ETH.Utils
  alias Ethereumex.HttpClient

  defdelegate parse(data), to: ETH.Transaction.Parser
  defdelegate to_list(data), to: ETH.Transaction.Parser

  defdelegate build(params), to: ETH.Transaction.Builder
  defdelegate build(wallet, params), to: ETH.Transaction.Builder
  defdelegate build(sender_wallet, receiver_wallet, params_or_value), to: ETH.Transaction.Builder

  defdelegate hash_transaction(transaction), to: ETH.Transaction.Signer
  defdelegate hash_transaction(transaction, include_signature), to: ETH.Transaction.Signer

  defdelegate sign_transaction(transaction, private_key), to: ETH.Transaction.Signer
  defdelegate decode(rlp_encoded_transaction), to: ETH.Transaction.Signer
  defdelegate encode(signed_transaction_list), to: ETH.Transaction.Signer

  # NOTE: raise if private_key isnt the one in the params from?
  def send_transaction(wallet, params) when is_map(params) do
    params
    |> Map.merge(%{from: wallet.eth_address})
    |> send_transaction(wallet.private_key)
  end

  def send_transaction(params, private_key, opts) do
    set_default_from(params, private_key)
    |> build
    |> sign_transaction(private_key)
    |> Base.encode16()
    |> send(opts)
  end

  def send_transaction(sender_wallet, receiver_wallet, value) when is_number(value) do
    %{from: sender_wallet.eth_address, to: receiver_wallet.eth_address, value: value}
    |> send_transaction(sender_wallet.private_key)
  end

  def send_transaction(sender_wallet, receiver_wallet, params) when is_map(params) do
    params
    |> Map.merge(%{from: sender_wallet.eth_address, to: receiver_wallet.eth_address})
    |> send_transaction(sender_wallet.private_key)
  end

  def send_transaction(sender_wallet, receiver_wallet, params) when is_list(params) do
    params
    |> Keyword.merge(from: sender_wallet.eth_address, to: receiver_wallet.eth_address)
    |> send_transaction(sender_wallet.private_key)
  end

  def send_transaction(sender_wallet, receiver_wallet, value, private_key)
      when is_number(value) do
    %{from: sender_wallet.eth_address, to: receiver_wallet.eth_address, value: value}
    |> send_transaction(private_key)
  end

  def send_transaction(sender_wallet, receiver_wallet, params, private_key) when is_map(params) do
    params
    |> Map.merge(%{from: sender_wallet.eth_address, to: receiver_wallet.eth_address})
    |> send_transaction(private_key)
  end

  def send_transaction(sender_wallet, receiver_wallet, params, private_key)
      when is_list(params) do
    params
    |> Keyword.merge(from: sender_wallet.eth_address, to: receiver_wallet.eth_address)
    |> send_transaction(private_key)
  end

  def send_transaction!(wallet, params) when is_map(params) do
    {:ok, tx_hash} =
      params
      |> Map.merge(%{from: wallet.eth_address})
      |> send_transaction(wallet.private_key)

    tx_hash
  end

  def send_transaction!(params, private_key) when is_list(params) do
    {:ok, tx_hash} =
      params
      |> send_transaction(private_key)

    tx_hash
  end

  def send_transaction!(params, private_key) when is_map(params) do
    {:ok, tx_hash} =
      params
      |> send_transaction(private_key)

    tx_hash
  end

  def send_transaction!(sender_wallet, receiver_wallet, value) when is_number(value) do
    {:ok, tx_hash} =
      %{from: sender_wallet.eth_address, to: receiver_wallet.eth_address, value: value}
      |> send_transaction(sender_wallet.private_key)

    tx_hash
  end

  def send_transaction!(sender_wallet, receiver_wallet, params) when is_map(params) do
    {:ok, tx_hash} =
      params
      |> Map.merge(%{from: sender_wallet.eth_address, to: receiver_wallet.eth_address})
      |> send_transaction(sender_wallet.private_key)

    tx_hash
  end

  def send_transaction!(sender_wallet, receiver_wallet, params) when is_list(params) do
    {:ok, tx_hash} =
      params
      |> Keyword.merge(from: sender_wallet.eth_address, to: receiver_wallet.eth_address)
      |> send_transaction(sender_wallet.private_key)

    tx_hash
  end

  def send_transaction!(sender_wallet, receiver_wallet, value, private_key)
      when is_number(value) do
    {:ok, tx_hash} =
      %{from: sender_wallet.eth_address, to: receiver_wallet.eth_address, value: value}
      |> send_transaction(private_key)

    tx_hash
  end

  def send_transaction!(sender_wallet, receiver_wallet, params, private_key)
      when is_map(params) do
    {:ok, tx_hash} =
      params
      |> Map.merge(%{from: sender_wallet.eth_address, to: receiver_wallet.eth_address})
      |> send_transaction(private_key)

    tx_hash
  end

  def send_transaction!(sender_wallet, receiver_wallet, params, private_key)
      when is_list(params) do
    {:ok, tx_hash} =
      params
      |> Keyword.merge(from: sender_wallet.eth_address, to: receiver_wallet.eth_address)
      |> send_transaction(private_key)

    tx_hash
  end

  def send(signature, opts), do: HttpClient.eth_send_raw_transaction(prepend0x(signature), opts)

  def send!(signature, opts) do
    {:ok, transaction_hash} = HttpClient.eth_send_raw_transaction(prepend0x(signature), opts)
    transaction_hash
  end

  def get_senders_public_key("0x" <> rlp_encoded_transaction_list) do
    rlp_encoded_transaction_list
    |> Base.decode16!(case: :mixed)
    |> get_senders_public_key
  end

  def get_senders_public_key(
        transaction_list = [
          _nonce,
          _gas_price,
          _gas_limit,
          _to,
          _value,
          _data,
          v,
          r,
          s
        ]
      ) do
    message_hash = hash_transaction(transaction_list, false)
    chain_id = get_chain_id(v, Enum.at(transaction_list, 9))
    v_int = buffer_to_int(v)
    target_v = if chain_id > 0, do: v_int - (chain_id * 2 + 8), else: v_int
    recovery_id = target_v - 27

    {:ok, public_key} = ExSecp256k1.recover_compact(message_hash, r <> s, recovery_id)

    public_key
  end

  def get_senders_public_key(decoded_tx_binary) do
    decoded_tx_binary
    |> ExRLP.decode()
    |> get_senders_public_key
  end

  def get_sender_address("0x" <> rlp_encoded_transaction_list) do
    rlp_encoded_transaction_list
    |> Base.decode16!(case: :mixed)
    |> ExRLP.decode()
    |> get_sender_address()
  end

  def get_sender_address(
        transaction_list = [
          _nonce,
          _gas_price,
          _gas_limit,
          _to,
          _value,
          _data,
          _v,
          _r,
          _s
        ]
      ) do
    get_senders_public_key(transaction_list)
    |> get_address
  end

  def get_sender_address(decoded_tx_binary) do
    decoded_tx_binary
    |> get_senders_public_key()
    |> get_address
  end

  defp set_default_from(params, private_key) when is_list(params) do
    put_in(params, [:from], Keyword.get_lazy(params, :from, fn -> get_address(private_key) end))
  end

  defp set_default_from(params, private_key) when is_map(params) do
    Map.merge(params, %{from: Map.get_lazy(params, :from, fn -> get_address(private_key) end)})
  end
end
