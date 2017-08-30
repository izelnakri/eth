defmodule ETH.QueryTest do
  use ExUnit.Case

  test "get_accounts/0 works" do
    accounts = ETH.Query.get_accounts

    assert accounts

    accounts |> Enum.each(fn(x) ->
      assert String.length(x) == 42
      assert String.slice(x, 0..1) == "0x"
    end)
  end

  test "get_balance/1 returns the balance of an ethereum address in ether by default" do
    address_with_balance = ETH.Query.get_accounts |> List.first
    address_with_no_balance = ETH.Wallet.create |> Map.get(:eth_address)

    assert ETH.Query.get_balance(address_with_balance) == 100.0
    assert ETH.Query.get_balance(address_with_no_balance) == 0.0
  end

  test "balance/1 returns the balance of an ethereum address with specific denomination" do
    address_with_balance = ETH.Query.get_accounts |> List.first
    address_with_no_balance = ETH.Wallet.create |> Map.get(:eth_address)

    assert ETH.Query.get_balance(address_with_balance, :wei) == 1.0e20
    assert ETH.Query.get_balance(address_with_no_balance, :wei) == 0.0
  end
end
