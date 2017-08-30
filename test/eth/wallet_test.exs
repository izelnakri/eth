defmodule ETH.WalletTest do
  use ExUnit.Case

  test "create/1 without private_key creates a random wallet" do
    wallet = ETH.Wallet.create()
    second_wallet = ETH.Wallet.create()

    assert wallet[:private_key]
    assert wallet[:private_key] != second_wallet[:private_key]
    assert wallet[:public_key]
    assert wallet[:public_key] == ETH.Utils.get_public_key(wallet[:private_key]) |> Base.encode16
    assert wallet[:public_key] != second_wallet[:public_key]
    assert wallet[:eth_address]
    assert wallet[:eth_address] == ETH.Utils.get_address(wallet[:public_key])
    assert wallet[:eth_address] != second_wallet[:eth_address]
  end

  test "create/1 without a specific raw private_key returns a specific wallet" do
    private_key = :crypto.strong_rand_bytes(32)
    wallet = ETH.Wallet.create(private_key)
    second_wallet = ETH.Wallet.create(Base.decode16!(wallet[:private_key]))

    assert wallet[:private_key]
    assert wallet[:private_key] == second_wallet[:private_key]
    assert wallet[:public_key]
    assert wallet[:public_key] == second_wallet[:public_key]
    assert wallet[:eth_address]
    assert wallet[:eth_address] == second_wallet[:eth_address]
  end

  test "create/1 without a specific base16 encoded private_key returns a specific wallet" do
    private_key = :crypto.strong_rand_bytes(32)
    wallet = ETH.Wallet.create(private_key)
    second_wallet = ETH.Wallet.create(wallet[:private_key])

    assert wallet[:private_key]
    assert wallet[:private_key] == second_wallet[:private_key]
    assert wallet[:public_key]
    assert wallet[:public_key] == second_wallet[:public_key]
    assert wallet[:eth_address]
    assert wallet[:eth_address] == second_wallet[:eth_address]
  end
end
