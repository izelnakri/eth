# NOTE: PASSING
defmodule ETH.Test do
  use ExUnit.Case

  test "public api holds all the methods" do
    assert ETH.__info__(:functions) == [
             block_number: 0,
             block_number!: 0,
             buffer_to_int: 1,
             build: 1,
             build: 2,
             build: 3,
             call: 1,
             call: 2,
             call!: 1,
             call!: 2,
             convert: 2,
             decode: 1,
             decode16: 1,
             encode: 1,
             encode16: 1,
             estimate_gas: 1,
             estimate_gas: 2,
             estimate_gas!: 1,
             estimate_gas!: 2,
             gas_price: 0,
             gas_price!: 0,
             get_accounts: 0,
             get_accounts!: 0,
             get_address: 1,
             get_balance: 1,
             get_balance: 2,
             get_balance: 3,
             get_balance!: 1,
             get_balance!: 2,
             get_balance!: 3,
             get_block: 0,
             get_block: 1,
             get_block!: 0,
             get_block!: 1,
             get_block_transaction_count: 1,
             get_block_transaction_count!: 1,
             get_block_transactions: 1,
             get_block_transactions!: 1,
             get_chain_id: 2,
             get_private_key: 0,
             get_public_key: 1,
             get_sender_address: 1,
             get_senders_public_key: 1,
             get_transaction: 1,
             get_transaction!: 1,
             get_transaction_count: 1,
             get_transaction_count: 2,
             get_transaction_count!: 1,
             get_transaction_count!: 2,
             get_transaction_from_block: 2,
             get_transaction_from_block!: 2,
             get_transaction_receipt: 1,
             get_transaction_receipt!: 1,
             hash_transaction: 1,
             hash_transaction: 2,
             pad_to_even: 1,
             parse: 1,
             secp256k1_signature: 2,
             send: 1,
             send!: 1,
             send_transaction: 2,
             send_transaction: 3,
             send_transaction: 4,
             send_transaction!: 2,
             send_transaction!: 3,
             send_transaction!: 4,
             sign_transaction: 2,
             syncing: 0,
             syncing!: 0,
             to_buffer: 1,
             to_list: 1
           ]
  end
end
