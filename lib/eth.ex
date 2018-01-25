defmodule ETH do
  @moduledoc """
  Elixir module that provides Ethereum utility functions
  """

  @doc """
  In order to use most of the functions in this library you need to be connected to an ethereum node.
  This could be your own self-hosted node running locally or a public proxy.

  ## Examples

      iex> ETH.block_number
      46080211

  """
  Application.put_env(:ethereumex, :url, Application.get_env(:eth, :url, "http://localhost:8545"))

  defdelegate block_number, to: ETH.Query
  defdelegate block_number!, to: ETH.Query
  defdelegate syncing, to: ETH.Query
  defdelegate syncing!, to: ETH.Query
  defdelegate get_accounts, to: ETH.Query
  defdelegate get_accounts!, to: ETH.Query
  defdelegate gas_price, to: ETH.Query
  defdelegate gas_price!, to: ETH.Query
  defdelegate call(call_params), to: ETH.Query
  defdelegate call!(call_params), to: ETH.Query
  defdelegate get_block, to: ETH.Query
  defdelegate get_block(identifier), to: ETH.Query
  defdelegate get_block!, to: ETH.Query
  defdelegate get_block!(identifier), to: ETH.Query
  defdelegate get_balance(wallet_or_address), to: ETH.Query
  defdelegate get_balance(wallet_or_address, denomination), to: ETH.Query
  defdelegate get_balance!(wallet_or_address), to: ETH.Query
  defdelegate get_balance!(wallet_or_address, denomination), to: ETH.Query
  defdelegate estimate_gas(transaction), to: ETH.Query
  defdelegate estimate_gas!(transaction), to: ETH.Query
  defdelegate estimate_gas(transaction, denomination), to: ETH.Query
  defdelegate estimate_gas!(transaction, denomination), to: ETH.Query

  defdelegate get_block_transactions(identifier), to: ETH.TransactionQueries
  defdelegate get_block_transactions!(identifier), to: ETH.TransactionQueries
  defdelegate get_block_transaction_count(identifier), to: ETH.TransactionQueries
  defdelegate get_block_transaction_count!(identifier), to: ETH.TransactionQueries
  defdelegate get_transaction_from_block(identifier, index), to: ETH.TransactionQueries
  defdelegate get_transaction_from_block!(identifier, index), to: ETH.TransactionQueries
  defdelegate get_transaction(transaction_hash), to: ETH.TransactionQueries
  defdelegate get_transaction!(transaction_hash), to: ETH.TransactionQueries
  defdelegate get_transaction_receipt(transaction_hash), to: ETH.TransactionQueries
  defdelegate get_transaction_receipt!(transaction_hash), to: ETH.TransactionQueries
  defdelegate get_transaction_count(wallet_or_address), to: ETH.TransactionQueries
  defdelegate get_transaction_count!(wallet_or_address), to: ETH.TransactionQueries

  defdelegate parse(data), to: ETH.Transaction.Parser
  defdelegate to_list(data), to: ETH.Transaction.Parser

  defdelegate build(params), to: ETH.Transaction.Builder
  defdelegate build(wallet, params), to: ETH.Transaction.Builder
  defdelegate build(sender_wallet, receiver_wallet, params_or_value), to: ETH.Transaction.Builder

  defdelegate hash_transaction(transaction), to: ETH.Transaction
  defdelegate hash_transaction(transaction, include_signature), to: ETH.Transaction

  defdelegate sign_transaction(transaction, private_key), to: ETH.Transaction.Signer
  defdelegate decode(rlp_encoded_transaction), to: ETH.Transaction.Signer
  defdelegate encode(signed_transaction_list), to: ETH.Transaction.Signer

  defdelegate send_transaction(params_or_wallet, private_key_or_params), to: ETH.Transaction

  defdelegate send_transaction(sender_wallet, receiver_wallet, value_or_params),
    to: ETH.Transaction

  defdelegate send_transaction(sender_wallet, receiver_wallet, value_or_params, private_key),
    to: ETH.Transaction

  defdelegate send_transaction!(params_or_wallet, private_key_or_params), to: ETH.Transaction

  defdelegate send_transaction!(sender_wallet, receiver_wallet, value_or_params),
    to: ETH.Transaction

  defdelegate send_transaction!(sender_wallet, receiver_wallet, value_or_params, private_key),
    to: ETH.Transaction

  defdelegate send(signature), to: ETH.Transaction
  defdelegate send!(signature), to: ETH.Transaction
  defdelegate get_senders_public_key(transaction_input), to: ETH.Transaction
  defdelegate get_sender_address(transaction_input), to: ETH.Transaction

  defdelegate get_private_key, to: ETH.Utils
  defdelegate get_public_key(private_key), to: ETH.Utils
  defdelegate get_address(private_or_public_key), to: ETH.Utils
  defdelegate convert(value, denomination), to: ETH.Utils
  defdelegate secp256k1_signature(hash, private_key), to: ETH.Utils
  defdelegate keccak256(data), to: ETH.Utils
  defdelegate encode16(data), to: ETH.Utils
  defdelegate decode16(decoded_data), to: ETH.Utils
  defdelegate to_buffer(data), to: ETH.Utils
  defdelegate buffer_to_int(data), to: ETH.Utils
  defdelegate pad_to_even(data), to: ETH.Utils
  defdelegate get_chain_id(v, chain_id), to: ETH.Utils
end
