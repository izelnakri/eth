# NOTE: PASSING
defmodule ETH.ETH.Signer.Test do
  use ExUnit.Case
  import ETH.Utils

  @eip155_transactions File.read!("test/fixtures/eip155_vitalik_tests.json") |> Poison.decode!()
  @transactions File.read!("test/fixtures/transactions.json") |> Poison.decode!()
  @encoded_example_private_key "75c3b11e480f8ba3db792424bebda1fc8dea2b254287e3a9af9ed50c7d255720"
  @decoded_example_private_key Base.decode16!(
                                 "75c3b11e480f8ba3db792424bebda1fc8dea2b254287e3a9af9ed50c7d255720",
                                 case: :mixed
                               )

  setup_all do
    ETH.TestClient.start()

    on_exit(fn ->
      ETH.TestClient.stop()
    end)

    :ok
  end

  test "hash/2 works" do
    @eip155_transactions
    |> Enum.each(fn transaction ->
      target_transaction =
        transaction
        |> Map.get("transaction")

      transaction_hash =
        ETH.parse(%{
          data: target_transaction["data"],
          gas_limit: target_transaction["gasLimit"],
          gas_price: target_transaction["gasPrice"],
          nonce: target_transaction["nonce"],
          r: target_transaction["r"],
          s: target_transaction["s"],
          to: target_transaction["to"],
          v: target_transaction["v"],
          value: target_transaction["value"]
        })
        |> ETH.to_list()
        |> ETH.hash_transaction(false)

      assert transaction_hash |> Base.encode16(case: :lower) == transaction |> Map.get("hash")
    end)

    example_transaction =
      @eip155_transactions
      |> Enum.at(0)
      |> Map.get("transaction")

    example_transaction_map =
      ETH.parse(%{
        data: example_transaction["data"],
        gas_limit: example_transaction["gasLimit"],
        gas_price: example_transaction["gasPrice"],
        nonce: example_transaction["nonce"],
        r: example_transaction["r"],
        s: example_transaction["s"],
        to: example_transaction["to"],
        v: example_transaction["v"],
        value: example_transaction["value"]
      })

    target_hash = "E0BE81F8D506DBE3A5549E720B51EB79492378D6638087740824F168667E5239"

    assert ETH.hash_transaction(example_transaction_map, false) |> Base.encode16() == target_hash

    next_target_hash = "25465F8B50446A4AB4269ACC6DB9D0D48A196C8F7E02B06881FEC6ABFF5C6C12"

    assert ETH.hash_transaction(example_transaction_map) |> Base.encode16() == next_target_hash

    assert ETH.hash_transaction(example_transaction_map, true) |> Base.encode16() ==
             next_target_hash

    example_transaction_list =
      @transactions
      |> Enum.at(2)
      |> Map.get("raw")
      |> ETH.parse()
      |> ETH.to_list()

    assert ETH.hash_transaction(example_transaction_list) ==
             decode16("375a8983c9fc56d7cfd118254a80a8d7403d590a6c9e105532b67aca1efb97aa")

    assert ETH.hash_transaction(example_transaction_list, false) ==
             decode16("61e1ec33764304dddb55348e7883d4437426f44ab3ef65e6da1e025734c03ff0")

    assert ETH.hash_transaction(example_transaction_list, true) ==
             decode16("375a8983c9fc56d7cfd118254a80a8d7403d590a6c9e105532b67aca1efb97aa")
  end

  test "sign_transaction works for transaction maps with encoded private keys" do
    output =
      ETH.build(%{
        nonce: 1,
        to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
        value: 22,
        gas_limit: 100_000,
        gas_price: 1000,
        from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
      })
      |> ETH.sign_transaction(@encoded_example_private_key)
      |> Base.encode16(case: :lower)

    serialized_hash =
      "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"

    assert output == serialized_hash
  end

  test "sign_transaction works for transaction maps with decoded private keys" do
    output =
      ETH.build(%{
        nonce: 1,
        to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
        value: 22,
        gas_limit: 100_000,
        gas_price: 1000,
        from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
      })
      |> ETH.sign_transaction(@decoded_example_private_key)
      |> Base.encode16(case: :lower)

    serialized_hash =
      "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"

    assert output == serialized_hash
  end

  test "sign_transaction works for transaction lists with encoded private keys" do
    output =
      ETH.build(%{
        nonce: 1,
        to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
        value: 22,
        gas_limit: 100_000,
        gas_price: 1000,
        from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
      })
      |> ETH.to_list()
      |> ETH.sign_transaction(@encoded_example_private_key)
      |> Base.encode16(case: :lower)

    serialized_hash =
      "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"

    assert output == serialized_hash
  end

  test "sign_transaction works for transaction lists with decoded private keys" do
    output =
      ETH.build(%{
        nonce: 1,
        to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
        value: 22,
        gas_limit: 100_000,
        gas_price: 1000,
        from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
      })
      |> ETH.to_list()
      |> ETH.sign_transaction(@decoded_example_private_key)
      |> Base.encode16(case: :lower)

    serialized_hash =
      "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"

    assert output == serialized_hash
  end
end
