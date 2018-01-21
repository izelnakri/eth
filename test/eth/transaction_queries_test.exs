defmodule ETH.TransactionQueries.Test do
  use ExUnit.Case

  @first_client_account_private_key "a160512c1dc5c33eff6ef89aae083108dcdcabdbe463481949d327fc2ac6ac48"

  # TODO: ETH.get_block_transactions

  # TODO: ETH.get_block_transactions_count

  # TODO: get_transaction_from_block!(identifier, index), to: ETH.Query

  # TODO: get_transaction

  # TODO: get_transaction_receipt

  test "transaction_count/1 works" do
    # TODO: have one with transactions
    address_with_balance = ETH.get_accounts!() |> List.last()

    assert ETH.get_transaction_count(address_with_balance) == {:ok, 0}

    wallet_with_balance = @first_client_account_private_key |> ETH.Wallet.create()

    assert ETH.get_transaction_count(wallet_with_balance) == {:ok, 0}
  end

  test "transaction_count!/1 works" do
    # TODO: have one with transactions
    address_with_balance = ETH.get_accounts!() |> List.last()

    assert ETH.get_transaction_count!(address_with_balance) == 0

    wallet_with_balance = @first_client_account_private_key |> ETH.Wallet.create()

    assert ETH.get_transaction_count!(wallet_with_balance) == 0
  end
end
