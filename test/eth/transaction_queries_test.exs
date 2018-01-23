# TODO: alot of the functions not tested!
defmodule ETH.TransactionQueries.Test do
  use ExUnit.Case

  setup_all do
    ETH.TestClient.start

    on_exit fn ->
      ETH.TestClient.stop
    end

    :ok
  end

  @first_client_account_private_key "a160512c1dc5c33eff6ef89aae083108dcdcabdbe463481949d327fc2ac6ac48"

  # TODO: ETH.get_block_transactions
  test "get_block_transactions/1 works" do
    first_block_transactions_by_number = ETH.get_block_transactions(1)

    first_block_transactions_by_hash =
      ETH.get_block!(1)
      |> Map.get(:hash)
      |> ETH.get_block_transactions()

    wallet = ETH.Wallet.create()
    first_account_in_your_client = ETH.Wallet.create(@first_client_account_private_key)

    # ETH.send_transaction(%{
    #   from: first_account_in_your_client.eth_address, to: wallet[:eth_address], value: 22
    # }, @first_client_account_private_key)
    # ETH.send_transaction(%{
    #   from: first_account_in_your_client.eth_address, to: wallet[:eth_address], value: 22
    # }, @first_client_account_private_key)

    assert first_block_transactions_by_number == {:ok, []}
    assert first_block_transactions_by_hash == {:ok, []}

    # last_block_transactions_by_number = ETH.block_number |> ETH.get_block_transactions
    # last_block_transactions_by_hash = ETH.block_number
    #   |> ETH.get_block
    #   |> Map.get(:hash)
    #   |> ETH.get_block_transactions
    #
    # assert last_block_transactions_by_number == {:ok, []}
    # assert last_block_transactions_by_hash == {:ok, []}
  end

  test "get_block_transactions!/1 works" do
    first_block_transactions_by_number = ETH.get_block_transactions!(1)

    first_block_transactions_by_hash =
      ETH.get_block!(1)
      |> Map.get(:hash)
      |> ETH.get_block_transactions!()

    wallet = ETH.Wallet.create()
    first_account_in_your_client = ETH.Wallet.create(@first_client_account_private_key)

    # ETH.send_transaction(%{
    #   from: first_account_in_your_client.eth_address, to: wallet[:eth_address], value: 22
    # }, @first_client_account_private_key)
    # ETH.send_transaction(%{
    #   from: first_account_in_your_client.eth_address, to: wallet[:eth_address], value: 22
    # }, @first_client_account_private_key)

    assert first_block_transactions_by_number == []
    assert first_block_transactions_by_hash == []

    # last_block_transactions_by_number = ETH.block_number |> ETH.get_block_transactions
    # last_block_transactions_by_hash = ETH.block_number
    #   |> ETH.get_block
    #   |> Map.get(:hash)
    #   |> ETH.get_block_transactions
    #
    # assert last_block_transactions_by_number == {:ok, []}
    # assert last_block_transactions_by_hash == {:ok, []}
  end

  test "get_block_transactions_count/1 works" do
    assert ETH.get_block_transaction_count(1) == {:ok, 0}
    assert ETH.get_block!() |> Map.get(:hash) |> ETH.get_transaction_count() == {:ok, 0}

    # wallet = ETH.Wallet.create()
    # first_account_in_your_client = ETH.Wallet.create(@first_client_account_private_key)

    # ETH.send_transaction(%{
    #   from: first_account_in_your_client.eth_address, to: wallet[:eth_address], value: 22
    # }, @first_client_account_private_key)
    # ETH.send_transaction(%{
    #   from: first_account_in_your_client.eth_address, to: wallet[:eth_address], value: 22
    # }, @first_client_account_private_key)

    # assert ETH.block_number!() |> ETH.get_block_transaction_count() == {:ok, 2}
    # assert ETH.block_number!() |> Map.get(:hash) |> ETH.get_transaction_count() == {:ok, 2}
  end

  test "get_block_transactions_count!/1 works" do
    assert ETH.get_block_transaction_count!(1) == 0
    assert ETH.get_block!() |> Map.get(:hash) |> ETH.get_transaction_count!() == 0

    # wallet = ETH.Wallet.create()
    # first_account_in_your_client = ETH.Wallet.create(@first_client_account_private_key)

    # ETH.send_transaction(%{
    #   from: first_account_in_your_client.eth_address, to: wallet[:eth_address], value: 22
    # }, @first_client_account_private_key)
    # ETH.send_transaction(%{
    #   from: first_account_in_your_client.eth_address, to: wallet[:eth_address], value: 22
    # }, @first_client_account_private_key)

    # assert ETH.block_number!() |> ETH.get_block_transaction_count() == 2
    # assert ETH.block_number!() |> Map.get(:hash) |> ETH.get_transaction_count() == 2
  end

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
