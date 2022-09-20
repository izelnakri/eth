defmodule ETH.Transaction.Signer do
  import ETH.Utils

  alias ETH.Transaction.Parser, as: TransactionParser

  @moduledoc """
    This module hashes or signs ethereum transactions provided as a transaction map or a list.
  """

  def decode(<<rlp_encoded_transaction_list>>), do: ExRLP.decode(rlp_encoded_transaction_list)

  def encode(transaction_list = [_nonce, _gas_price, _gas_limit, _to, _value, _data, _v, _r, _s]) do
    ExRLP.encode(transaction_list)
  end

  def hash_transaction(transaction, include_signature \\ true)

  def hash_transaction(transaction_list, include_signature) when is_list(transaction_list) do
    target_list =
      case include_signature do
        true ->
          transaction_list

        false ->
          # EIP155 spec:
          # when computing the hash of a transaction for purposes of signing or recovering,
          # instead of hashing only the first six elements (ie. nonce, gasprice, startgas, to, value, data),
          # hash nine elements, with v replaced by CHAIN_ID, r = 0 and s = 0
          list = Enum.take(transaction_list, 6)
          v = Enum.at(transaction_list, 6) || <<28>>
          chain_id = get_chain_id(v, Enum.at(transaction_list, 9))
          if chain_id > 0, do: list ++ [chain_id, 0, 0], else: list
      end

    target_list
    |> ExRLP.encode()
    |> ExKeccak.hash_256
  end

  def hash_transaction(
        transaction = %{
          to: _to,
          value: _value,
          data: _data,
          gas_price: _gas_price,
          gas_limit: _gas_limit,
          nonce: _nonce
        },
        include_signature
      ) do
    chain_id = get_chain_id(Map.get(transaction, :v, <<28>>), Map.get(transaction, :chain_id))

    transaction
    |> Map.delete(:chain_id)
    |> TransactionParser.to_list()
    |> List.insert_at(-1, chain_id)
    |> hash_transaction(include_signature)
  end

  def sign_transaction(transaction, private_key) when is_map(transaction) do
    transaction
    |> ETH.Transaction.to_list()
    |> sign_transaction(private_key)
  end

  def sign_transaction(
        transaction_list = [
          _nonce,
          _gas_price,
          _gas_limit,
          _to,
          _value,
          _data,
          _v,
          _r,
          _s,
          _chain_id
        ],
        <<private_key::binary-size(32)>>
      )
      when is_list(transaction_list) do
    sign_transaction_list(transaction_list, private_key)
  end

  def sign_transaction(
        transaction_list = [
          _nonce,
          _gas_price,
          _gas_limit,
          _to,
          _value,
          _data,
          _v,
          _r,
          _s,
          _chain_id
        ],
        <<encoded_private_key::binary-size(64)>>
      )
      when is_list(transaction_list) do
    decoded_private_key = Base.decode16!(encoded_private_key, case: :mixed)
    sign_transaction_list(transaction_list, decoded_private_key)
  end

  defp sign_transaction_list(
         transaction_list = [
           nonce,
           gas_price,
           gas_limit,
           to,
           value,
           data,
           v,
           _r,
           _s,
           _chain_id
         ],
         <<private_key::binary-size(32)>>
       ) do
    chain_id = get_chain_id(v, Enum.at(transaction_list, 9))

    <<chain_id_int>> = chain_id

    message_hash = hash_transaction(transaction_list, false)

    [signature: signature, recovery: recovery] = secp256k1_signature(message_hash, private_key)

    <<sig_r::binary-size(32)>> <> <<sig_s::binary-size(32)>> = signature
    initial_v = recovery + 27

    sig_v = if chain_id_int > 0, do: initial_v + (chain_id_int * 2 + 8), else: initial_v


    [nonce, gas_price, gas_limit, to, value, data, <<sig_v>>, sig_r, sig_s]
    |> ExRLP.encode()
  end
end
