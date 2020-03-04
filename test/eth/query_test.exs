# NOTE: PASSING
# TODO: ETH.call
defmodule ETH.Query.Test do
  use ExUnit.Case

  setup_all do
    ETH.TestClient.start()

    on_exit(fn ->
      ETH.TestClient.stop()
    end)

    :ok
  end

  @first_client_account_private_key "a160512c1dc5c33eff6ef89aae083108dcdcabdbe463481949d327fc2ac6ac48"

  test "block_number/0 works" do
    result = ETH.block_number()

    assert result |> elem(0) == :ok
    assert result |> elem(1) |> is_integer
  end

  test "block_number!/0 works" do
    assert is_integer(ETH.block_number!())
  end

  test "syncing/0 works" do
    assert ETH.syncing() == {:ok, false}
  end

  test "syncing!/0 works" do
    assert ETH.syncing!() == false
  end

  test "get_accounts/0 works" do
    result = ETH.get_accounts()

    assert result |> elem(0) == :ok

    result
    |> elem(1)
    |> Enum.each(fn x ->
      assert String.length(x) == 42
      assert String.slice(x, 0..1) == "0x"
    end)
  end

  test "get_accounts!/0 works" do
    ETH.get_accounts!()
    |> Enum.each(fn x ->
      assert String.length(x) == 42
      assert String.slice(x, 0..1) == "0x"
    end)
  end

  test "gas_price/0 works" do
    result = ETH.gas_price()

    assert result |> elem(0) == :ok
    assert result |> elem(1) > 0
  end

  test "gas_price!/0 works" do
    assert ETH.gas_price!() > 0
  end

  # TODO: ETH.call

  test "get_block/0 works" do
    result = ETH.get_block()
    current_block = result |> elem(1)

    assert result |> elem(0) == :ok
    assert current_block.number == ETH.block_number!()

    assert Map.keys(current_block) == [
             :difficulty,
             :extra_data,
             :gas_limit,
             :gas_used,
             :hash,
             :logs_bloom,
             :miner,
             :mix_hash,
             :nonce,
             :number,
             :parent_hash,
             :receipts_root,
             :sha3_uncles,
             :size,
             :state_root,
             :timestamp,
             :total_difficulty,
             :transactions,
             :transactions_root,
             :uncles
           ]
  end

  test "get_block/1 by number works" do
    ETH.TestClient.advance_block_by(1)

    target_result = ETH.get_block(2)
    target_block = target_result |> elem(1)

    assert target_result |> elem(0) == :ok
    assert target_block.number == 2
    assert target_block.number != ETH.get_block!(1) |> Map.get(:number)

    assert Map.keys(target_block) == [
             :difficulty,
             :extra_data,
             :gas_limit,
             :gas_used,
             :hash,
             :logs_bloom,
             :miner,
             :mix_hash,
             :nonce,
             :number,
             :parent_hash,
             :receipts_root,
             :sha3_uncles,
             :size,
             :state_root,
             :timestamp,
             :total_difficulty,
             :transactions,
             :transactions_root,
             :uncles
           ]
  end

  test "get_block/1 by hash works" do
    {:ok, first_block} = ETH.get_block(1)
    {:ok, second_block} = ETH.get_block(2)

    assert ETH.get_block(first_block.hash) |> elem(1) == first_block
    assert ETH.get_block(second_block.hash) |> elem(1) == second_block
  end

  test "get_block!/0 works" do
    current_block = ETH.get_block!()

    assert current_block.number == ETH.block_number!()

    assert Map.keys(current_block) == [
             :difficulty,
             :extra_data,
             :gas_limit,
             :gas_used,
             :hash,
             :logs_bloom,
             :miner,
             :mix_hash,
             :nonce,
             :number,
             :parent_hash,
             :receipts_root,
             :sha3_uncles,
             :size,
             :state_root,
             :timestamp,
             :total_difficulty,
             :transactions,
             :transactions_root,
             :uncles
           ]
  end

  test "get_block!/1 by number works" do
    ETH.TestClient.advance_block_by(1)

    target_block = ETH.get_block!(2)

    assert target_block.number == 2
    assert target_block.number != ETH.get_block!(1) |> Map.get(:number)

    assert Map.keys(target_block) == [
             :difficulty,
             :extra_data,
             :gas_limit,
             :gas_used,
             :hash,
             :logs_bloom,
             :miner,
             :mix_hash,
             :nonce,
             :number,
             :parent_hash,
             :receipts_root,
             :sha3_uncles,
             :size,
             :state_root,
             :timestamp,
             :total_difficulty,
             :transactions,
             :transactions_root,
             :uncles
           ]
  end

  test "get_block!/1 by hash works" do
    ETH.TestClient.advance_block_by(1)

    first_block = ETH.get_block!(1)
    second_block = ETH.get_block!(2)

    assert ETH.get_block!(first_block.hash) == first_block
    assert ETH.get_block!(second_block.hash) == second_block
  end

  test "get_balance/1 returns the balance of an ethereum address in ether by default" do
    address_with_balance = ETH.get_accounts!() |> List.last()
    address_with_no_balance = ETH.Wallet.create() |> Map.get(:eth_address)

    assert ETH.get_balance(address_with_balance) == {:ok, 100.0}
    assert ETH.get_balance(address_with_no_balance) == {:ok, 0.0}
  end

  test "balance/1 returns the balance of an ethereum address with specific denomination" do
    address_with_balance = ETH.get_accounts!() |> List.last()
    address_with_no_balance = ETH.Wallet.create() |> Map.get(:eth_address)

    assert ETH.get_balance(address_with_balance, :wei) == {:ok, 1.0e20}
    assert ETH.get_balance(address_with_no_balance, :wei) == {:ok, 0.0}
  end

  test "get_balance/1 returns the balance of an ethereum wallet in ether by default" do
    wallet_with_balance = @first_client_account_private_key |> ETH.Wallet.create()
    wallet_with_no_balance = ETH.Wallet.create()

    assert ETH.get_balance(wallet_with_balance) == {:ok, 100.0}
    assert ETH.get_balance(wallet_with_no_balance) == {:ok, 0.0}
  end

  test "get_balance/1 returns the balance of an ethereum wallet with specific denomination" do
    wallet_with_balance = @first_client_account_private_key |> ETH.Wallet.create()
    wallet_with_no_balance = ETH.Wallet.create()

    assert ETH.get_balance(wallet_with_balance, :wei) == {:ok, 1.0e20}
    assert ETH.get_balance(wallet_with_no_balance, :wei) == {:ok, 0.0}
  end

  test "get_balance!/1 returns the balance of an ethereum address in ether by default" do
    address_with_balance = ETH.get_accounts!() |> List.last()
    address_with_no_balance = ETH.Wallet.create() |> Map.get(:eth_address)

    assert ETH.get_balance!(address_with_balance) == 100.0
    assert ETH.get_balance!(address_with_no_balance) == 0.0
  end

  test "get_balance!/1 returns the balance of an ethereum address with specific denomination" do
    address_with_balance = ETH.get_accounts!() |> List.last()
    address_with_no_balance = ETH.Wallet.create() |> Map.get(:eth_address)

    assert ETH.get_balance!(address_with_balance, :wei) == 1.0e20
    assert ETH.get_balance!(address_with_no_balance, :wei) == 0.0
  end

  test "get_balance!/1 returns the balance of an ethereum wallet in ether by default" do
    wallet_with_balance = @first_client_account_private_key |> ETH.Wallet.create()
    wallet_with_no_balance = ETH.Wallet.create()

    assert ETH.get_balance!(wallet_with_balance) == 100.0
    assert ETH.get_balance!(wallet_with_no_balance) == 0.0
  end

  test "get_balance!/1 returns the balance of an ethereum wallet with specific denomination" do
    wallet_with_balance = @first_client_account_private_key |> ETH.Wallet.create()
    wallet_with_no_balance = ETH.Wallet.create()

    assert ETH.get_balance!(wallet_with_balance, :wei) == 1.0e20
    assert ETH.get_balance!(wallet_with_no_balance, :wei) == 0.0
  end

  test "estimate_gas/2 works with default wei denomination" do
    address_with_balance = ETH.get_accounts!() |> List.last()

    assert ETH.estimate_gas(%{to: address_with_balance, data: ""}) == {:ok, 2.1e4}
    assert ETH.estimate_gas(%{to: address_with_balance, data: "asd"}) == {:ok, 21016}
  end

  test "estimate_gas/2 works with different denomination" do
    address = ETH.get_accounts!() |> List.first()
    {:ok, first_gas_in_ether} = ETH.estimate_gas(%{to: address, data: ""})
    {:ok, second_gas_in_ether} = ETH.estimate_gas(%{to: address, data: "asd"})

    {:ok, first_gas_in_wei} = ETH.estimate_gas(%{to: address, data: ""}, :wei)
    {:ok, second_gas_in_wei} = ETH.estimate_gas(%{to: address, data: "asd"}, :wei)

    assert first_gas_in_wei == 21000
    assert second_gas_in_wei == 21016

    first_difference = first_gas_in_ether / second_gas_in_ether
    second_difference = first_gas_in_wei / second_gas_in_wei
    assert Float.floor(first_difference, 15) == Float.floor(second_difference, 15)
  end

  test "estimate_gas!/2 works with default wei denomination" do
    address_with_balance = ETH.get_accounts!() |> List.last()

    assert ETH.estimate_gas!(%{to: address_with_balance, data: ""}) == 2.1e4
    assert ETH.estimate_gas!(%{to: address_with_balance, data: "asd"}) == 21016
  end

  test "estimate_gas!/2 works with different denomination" do
    address = ETH.get_accounts!() |> List.first()
    first_gas_in_ether = ETH.estimate_gas!(%{to: address, data: ""})
    second_gas_in_ether = ETH.estimate_gas!(%{to: address, data: "asd"})

    first_gas_in_wei = ETH.estimate_gas!(%{to: address, data: ""}, :wei)
    second_gas_in_wei = ETH.estimate_gas!(%{to: address, data: "asd"}, :wei)

    assert first_gas_in_wei == 21000
    assert second_gas_in_wei == 21016

    first_difference = first_gas_in_ether / second_gas_in_ether
    second_difference = first_gas_in_wei / second_gas_in_wei

    assert Float.floor(first_difference, 15) == Float.floor(second_difference, 15)
  end
end
