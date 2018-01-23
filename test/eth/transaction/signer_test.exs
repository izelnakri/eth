require IEx

defmodule ETH.Transaction.Signer.Test do
  use ExUnit.Case
  import ETH.Utils

  alias ETH.Transaction

  @transactions File.read!("test/fixtures/transactions.json") |> Poison.decode!()
  @first_example_transaction %{
    nonce: "0x00",
    gas_price: "0x09184e72a000",
    gas_limit: "0x2710",
    to: "0x0000000000000000000000000000000000000000",
    value: "0x00",
    data: "0x7f7465737432000000000000000000000000000000000000000000000000000000600057",
    # EIP 155 chainId - mainnet: 1, ropsten: 3
    chain_id: 3
  }
  @encoded_example_private_key "75c3b11e480f8ba3db792424bebda1fc8dea2b254287e3a9af9ed50c7d255720"
  @decoded_example_private_key Base.decode16!("75c3b11e480f8ba3db792424bebda1fc8dea2b254287e3a9af9ed50c7d255720", case: :mixed)

  setup_all do
    ETH.TestClient.start

    on_exit fn ->
      ETH.TestClient.stop
    end

    :ok
  end

  test "hash/2 works" do
    target_hash = "DF2A7CB6D05278504959987A144C116DBD11CBDC50D6482C5BAE84A7F41E2113"

    assert Transaction.hash(@first_example_transaction, false) |> Base.encode16() == target_hash
    assert @first_example_transaction
           |> Transaction.to_list()
           |> List.insert_at(-1, @first_example_transaction.chain_id)
           |> Transaction.hash(false)
           |> Base.encode16() == target_hash

    next_target_hash = "B89EE1E3B4FF893AC8C435BE40EA94A1BA0EB3F64B48382DA967780BAFC8DBB1"

    assert Transaction.hash(@first_example_transaction) |> Base.encode16() == next_target_hash
    assert @first_example_transaction
           |> Transaction.to_list()
           |> List.insert_at(-1, @first_example_transaction.chain_id)
           |> Transaction.hash()
           |> Base.encode16() == next_target_hash

    assert Transaction.hash(@first_example_transaction, true) |> Base.encode16() == next_target_hash
    assert @first_example_transaction
          |> Transaction.to_list()
          |> List.insert_at(-1, @first_example_transaction.chain_id)
          |> Transaction.hash(true)
          |> Base.encode16() == next_target_hash


    first_transaction_list =
      @transactions
      |> Enum.at(2)
      |> Map.get("raw")
      |> Transaction.parse()
      |> Transaction.to_list()

    second_transaction_list =
      @transactions
      |> Enum.at(3)
      |> Map.get("raw")
      |> Transaction.parse()
      |> Transaction.to_list()

    assert Transaction.hash(first_transaction_list) ==
             decode16("375a8983c9fc56d7cfd118254a80a8d7403d590a6c9e105532b67aca1efb97aa")

    assert Transaction.hash(first_transaction_list, false) ==
             decode16("61e1ec33764304dddb55348e7883d4437426f44ab3ef65e6da1e025734c03ff0")

    assert Transaction.hash(first_transaction_list, true) ==
             decode16("375a8983c9fc56d7cfd118254a80a8d7403d590a6c9e105532b67aca1efb97aa")

    assert Transaction.hash(second_transaction_list) ==
             decode16("0f09dc98ea85b7872f4409131a790b91e7540953992886fc268b7ba5c96820e4")

    assert Transaction.hash(second_transaction_list, true) ==
             decode16("0f09dc98ea85b7872f4409131a790b91e7540953992886fc268b7ba5c96820e4")

    assert Transaction.hash(second_transaction_list, false) ==
             decode16("f97c73fdca079da7652dbc61a46cd5aeef804008e057be3e712c43eac389aaf0")
  end

  test "sign_transaction works for transaction maps with encoded private keys" do
    output =
      Transaction.build(%{
        nonce: 1,
        to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
        value: 22,
        gas_limit: 100_000,
        gas_price: 1000,
        from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
      })
      |> Transaction.sign_transaction(@encoded_example_private_key)
      |> Base.encode16(case: :lower)

    serialized_hash =
      "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"

    assert output == serialized_hash
  end

  test "sign_transaction works for transaction maps with decoded private keys" do
    output =
      Transaction.build(%{
        nonce: 1,
        to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
        value: 22,
        gas_limit: 100_000,
        gas_price: 1000,
        from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
      })
      |> Transaction.sign_transaction(@decoded_example_private_key)
      |> Base.encode16(case: :lower)

    serialized_hash =
      "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"

    assert output == serialized_hash
  end

  # TODO: should I add ExRLP.encode() to sign_transaction(transaction_lists) it also changes the test results of above
  # test "sign_transaction works for transaction lists with encoded private keys" do
  #   output =
  #     Transaction.build(%{
  #       nonce: 1,
  #       to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
  #       value: 22,
  #       gas_limit: 100_000,
  #       gas_price: 1000,
  #       from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
  #     })
  #     |> Transaction.to_list()
  #     |> Transaction.sign_transaction(@encoded_example_private_key)
  #     |> Base.encode16(case: :lower)
  #
  #   serialized_hash =
  #     "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"
  #
  #   assert output == serialized_hash
  # end
  #
  # test "sign_transaction works for transaction lists with decoded private keys" do
  #   output =
  #     Transaction.build(%{
  #       nonce: 1,
  #       to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
  #       value: 22,
  #       gas_limit: 100_000,
  #       gas_price: 1000,
  #       from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
  #     })
  #     |> Transaction.to_list()
  #     |> Transaction.sign_transaction(@decoded_example_private_key)
  #     |> Base.encode16(case: :lower)
  #
  #   serialized_hash =
  #     "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"
  #
  #   assert output == serialized_hash
  # end
end
