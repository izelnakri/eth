# NOTE: PASSING
defmodule ETH.WalletTest do
  use ExUnit.Case

  @first_client_account_private_key "a160512c1dc5c33eff6ef89aae083108dcdcabdbe463481949d327fc2ac6ac48"

  test "create/1 without private_key creates a random wallet" do
    wallet = ETH.Wallet.create()
    second_wallet = ETH.Wallet.create()

    assert wallet[:private_key]
    assert wallet[:private_key] != second_wallet[:private_key]
    assert wallet[:public_key]

    assert wallet[:public_key] == ETH.get_public_key(wallet[:private_key]) |> Base.encode16()

    assert wallet[:public_key] != second_wallet[:public_key]
    assert wallet[:eth_address]
    assert wallet[:eth_address] == ETH.get_address(wallet[:public_key])
    assert wallet[:eth_address] != second_wallet[:eth_address]

    assert wallet[:mnemonic_phrase]
    assert Mnemonic.mnemonic_to_entropy(wallet[:mnemonic_phrase]) == wallet[:private_key]
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
    assert wallet[:mnemonic_phrase]
    assert Mnemonic.mnemonic_to_entropy(wallet[:mnemonic_phrase]) == wallet[:private_key]

    known_wallet =
      ETH.Wallet.create(Base.decode16!(@first_client_account_private_key, case: :mixed))

    second_known_wallet = ETH.Wallet.create(@first_client_account_private_key)

    assert known_wallet[:private_key]
    assert known_wallet.eth_address == second_known_wallet.eth_address
    assert known_wallet[:public_key]
    assert known_wallet[:eth_address]
    assert known_wallet !== wallet
    assert known_wallet !== second_wallet
    assert known_wallet[:mnemonic_phrase]

    assert Mnemonic.mnemonic_to_entropy(known_wallet[:mnemonic_phrase]) ==
             known_wallet[:private_key]
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
    assert wallet[:mnemonic_phrase]
    assert Mnemonic.mnemonic_to_entropy(wallet[:mnemonic_phrase]) == Base.encode16(private_key)
  end
end
