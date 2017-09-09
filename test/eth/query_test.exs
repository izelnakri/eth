# TODO: write tests for get_transaction\1 and get_transaction_receipt\1
defmodule ETH.QueryTest do
  use ExUnit.Case

  test "block_number/0 works" do
    block_number = ETH.Query.block_number

    assert is_integer(block_number)
  end

  test "syncing/0 works" do
    assert ETH.Query.syncing == false
  end

  test "get_accounts/0 works" do
    accounts = ETH.Query.get_accounts

    assert accounts

    accounts |> Enum.each(fn(x) ->
      assert String.length(x) == 42
      assert String.slice(x, 0..1) == "0x"
    end)
  end

  test "get_balance/1 returns the balance of an ethereum address in ether by default" do
    address_with_balance = ETH.Query.get_accounts |> List.last
    address_with_no_balance = ETH.Wallet.create |> Map.get(:eth_address)

    assert ETH.Query.get_balance(address_with_balance) == 100.0
    assert ETH.Query.get_balance(address_with_no_balance) == 0.0
  end

  test "balance/1 returns the balance of an ethereum address with specific denomination" do
    address_with_balance = ETH.Query.get_accounts |> List.last
    address_with_no_balance = ETH.Wallet.create |> Map.get(:eth_address)

    assert ETH.Query.get_balance(address_with_balance, :wei) == 1.0e20
    assert ETH.Query.get_balance(address_with_no_balance, :wei) == 0.0
  end

  test "transaction_count/1 works" do
    address_with_balance = ETH.Query.get_accounts |> List.last

    assert ETH.Query.get_transaction_count(address_with_balance) == 0
  end

  test "estimate_gas/2 works with default wei denomination" do
    address_with_balance = ETH.Query.get_accounts |> List.last

    assert ETH.Query.estimate_gas(%{to: address_with_balance, data: ""}) == 2.1e4
    assert ETH.Query.estimate_gas(%{to: address_with_balance, data: "asd"}) == 21340
  end

  # test "estimate_gas/2 works with different denomination" do
  #   address = ETH.Query.get_accounts |> List.first
  #   first_gas_in_ether = ETH.Query.estimate_gas(%{to: address, data: ""})
  #   second_gas_in_ether = ETH.Query.estimate_gas(%{to: address, data: "asd"})
  #
  #   first_gas_in_wei = ETH.Query.estimate_gas(%{to: address, data: ""}, :wei)
  #   second_gas_in_wei = ETH.Query.estimate_gas(%{to: address, data: "asd"}, :wei)
  #
  #   assert first_gas_in_wei == 21000
  #   assert second_gas_in_wei == 21340
  #
  #   first_difference = first_gas_in_ether / second_gas_in_ether
  #   second_difference = first_gas_in_wei / second_gas_in_wei
  #   assert Float.floor(first_difference, 15) == Float.floor(second_difference, 15)
  # end
end
