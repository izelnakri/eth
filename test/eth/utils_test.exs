# NOTE: bottom half not tested(do it last)
defmodule ETH.UtilsTest do
  use ExUnit.Case

  test "get_private_key/0 works" do
    assert ETH.get_private_key() |> byte_size == 32
    assert ETH.get_private_key() != ETH.get_private_key()
  end

  test "get_public_key/1 works" do
    private_key = :crypto.strong_rand_bytes(32)
    another_private_key = :crypto.strong_rand_bytes(32)
    public_key = ETH.get_public_key(private_key)

    assert public_key |> byte_size == 65
    assert public_key == ETH.get_public_key(private_key)
    assert public_key != ETH.get_public_key(another_private_key)

    1..1000
    |> Enum.each(fn _ ->
      private_key = :crypto.strong_rand_bytes(32)
      ETH.get_public_key(private_key)
    end)
  end

  test "get_public_key/1 works for encoded private keys" do
    private_key = :crypto.strong_rand_bytes(32) |> Base.encode16()
    another_private_key = :crypto.strong_rand_bytes(32) |> Base.encode16()
    public_key = ETH.get_public_key(private_key)

    assert public_key |> byte_size == 65
    assert public_key == ETH.get_public_key(private_key)
    assert public_key != ETH.get_public_key(another_private_key)
  end

  test "get_address/1 works for private keys" do
    private_key = :crypto.strong_rand_bytes(32)
    another_private_key = :crypto.strong_rand_bytes(32)
    eth_address = ETH.get_address(private_key)

    assert eth_address |> byte_size == 42
    assert eth_address == ETH.get_address(private_key)
    assert eth_address |> String.slice(0, 2) == "0x"
    assert eth_address != ETH.get_address(another_private_key)
  end

  test "get_address/1 works for encoded private keys" do
    private_key = :crypto.strong_rand_bytes(32)
    another_private_key = :crypto.strong_rand_bytes(32)
    eth_address = ETH.get_address(private_key |> Base.encode16())

    assert eth_address |> byte_size == 42
    assert eth_address == ETH.get_address(private_key |> Base.encode16())
    assert eth_address |> String.slice(0, 2) == "0x"
    assert eth_address != ETH.get_address(another_private_key)
  end

  test "get_address/1 works for public keys" do
    private_key = :crypto.strong_rand_bytes(32) |> Base.encode16()
    public_key = ETH.get_public_key(private_key)
    eth_address = ETH.get_address(public_key)

    another_private_key = :crypto.strong_rand_bytes(32) |> Base.encode16()
    another_public_key = ETH.get_public_key(another_private_key) |> Base.encode16()
    another_eth_address = ETH.get_address(another_public_key)

    assert eth_address |> byte_size == 42
    assert eth_address == ETH.get_address(public_key)
    assert eth_address == ETH.get_address(private_key)
    assert eth_address |> String.slice(0, 2) == "0x"
    assert eth_address != another_eth_address
    assert eth_address != ETH.get_address(another_private_key)
  end

  test "get_address/1 works for encoded public keys" do
    private_key = :crypto.strong_rand_bytes(32)
    public_key = ETH.get_public_key(private_key)
    eth_address = ETH.get_address(public_key |> Base.encode16())

    another_private_key = :crypto.strong_rand_bytes(32)
    another_public_key = ETH.get_public_key(another_private_key)
    another_eth_address = ETH.get_address(another_public_key |> Base.encode16())

    assert eth_address |> byte_size == 42
    assert eth_address == ETH.get_address(public_key |> Base.encode16())
    assert eth_address == ETH.get_address(private_key |> Base.encode16())
    assert eth_address |> String.slice(0, 2) == "0x"
    assert eth_address != another_eth_address
    assert eth_address != ETH.get_address(another_private_key |> Base.encode16())
  end

  test "secp256k1_signature/2 works" do
    hash =
      "5c207a650b59a8c2d1271f5cbda78a658cb411a87271d68062e61ab1a3f85cf9"
      |> Base.decode16!(case: :mixed)

    private_key =
      "e331b6d69882b4cb4ea581d88e0b604039a3de5967688d3dcffdd2270c0fd109"
      |> Base.decode16!(case: :mixed)

    target_signature =
      "c2a738b1eb84280399115f4bec9e52b8de494a3ea7d9f069277119a02de4a49876f3168913e968e9484e2e0e447cd7adc56505e25cbc372330793a31f0bf7195"

    secp256k1_signature = ETH.secp256k1_signature(hash, private_key)

    assert secp256k1_signature[:signature] |> Base.encode16(case: :lower) == target_signature
  end
end
