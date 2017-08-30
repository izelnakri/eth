defmodule ETH.UtilsTest do
  use ExUnit.Case

  test "get_private_key/0 works" do
    assert ETH.Utils.get_private_key |> byte_size == 32
    assert ETH.Utils.get_private_key != ETH.Utils.get_private_key
  end

  test "get_public_key/1 works" do
    private_key = :crypto.strong_rand_bytes(32)
    another_private_key = :crypto.strong_rand_bytes(32)
    public_key = ETH.Utils.get_public_key(private_key)

    assert public_key |> byte_size == 65
    assert public_key == ETH.Utils.get_public_key(private_key)
    assert public_key != ETH.Utils.get_public_key(another_private_key)
  end

  test "get_public_key/1 works for encoded private keys" do
    private_key = :crypto.strong_rand_bytes(32) |> Base.encode16
    another_private_key = :crypto.strong_rand_bytes(32) |> Base.encode16
    public_key = ETH.Utils.get_public_key(private_key)

    assert public_key |> byte_size == 65
    assert public_key == ETH.Utils.get_public_key(private_key)
    assert public_key != ETH.Utils.get_public_key(another_private_key)
  end

  test "get_address/1 works for private keys" do
    private_key = :crypto.strong_rand_bytes(32)
    another_private_key = :crypto.strong_rand_bytes(32)
    eth_address = ETH.Utils.get_address(private_key)

    assert eth_address |> byte_size == 42
    assert eth_address == ETH.Utils.get_address(private_key)
    assert eth_address |> String.slice(0, 2) == "0x"
    assert eth_address != ETH.Utils.get_address(another_private_key)
  end

  test "get_address/1 works for encoded private keys" do
    private_key = :crypto.strong_rand_bytes(32)
    another_private_key = :crypto.strong_rand_bytes(32)
    eth_address = ETH.Utils.get_address(private_key |> Base.encode16)

    assert eth_address |> byte_size == 42
    assert eth_address == ETH.Utils.get_address(private_key |> Base.encode16)
    assert eth_address |> String.slice(0, 2) == "0x"
    assert eth_address != ETH.Utils.get_address(another_private_key)
  end

  test "get_address/1 works for public keys" do
    private_key = :crypto.strong_rand_bytes(32) |> Base.encode16
    public_key = ETH.Utils.get_public_key(private_key)
    eth_address = ETH.Utils.get_address(public_key)

    another_private_key = :crypto.strong_rand_bytes(32) |> Base.encode16
    another_public_key = ETH.Utils.get_public_key(another_private_key) |> Base.encode16
    another_eth_address = ETH.Utils.get_address(another_public_key)

    assert eth_address |> byte_size == 42
    assert eth_address == ETH.Utils.get_address(public_key)
    assert eth_address == ETH.Utils.get_address(private_key)
    assert eth_address |> String.slice(0, 2) == "0x"
    assert eth_address != another_eth_address
    assert eth_address != ETH.Utils.get_address(another_private_key)
  end

  test "get_address/1 works for encoded public keys" do
    private_key = :crypto.strong_rand_bytes(32)
    public_key = ETH.Utils.get_public_key(private_key)
    eth_address = ETH.Utils.get_address(public_key |> Base.encode16)

    another_private_key = :crypto.strong_rand_bytes(32)
    another_public_key = ETH.Utils.get_public_key(another_private_key)
    another_eth_address = ETH.Utils.get_address(another_public_key |> Base.encode16)

    assert eth_address |> byte_size == 42
    assert eth_address == ETH.Utils.get_address(public_key |> Base.encode16)
    assert eth_address == ETH.Utils.get_address(private_key |> Base.encode16)
    assert eth_address |> String.slice(0, 2) == "0x"
    assert eth_address != another_eth_address
    assert eth_address != ETH.Utils.get_address(another_private_key |> Base.encode16)
  end
end
