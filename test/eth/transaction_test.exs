require IEx
defmodule ETH.TransactionTest do
  use ExUnit.Case
  import ETH.Utils

  @first_example_wallet %{
    private_key: "e331b6d69882b4cb4ea581d88e0b604039a3de5967688d3dcffdd2270c0fd109"
  }
  @first_example_transaction %{
    nonce: "0x00",
    gas_price: "0x09184e72a000",
    gas_limit: "0x2710",
    to: "0x0000000000000000000000000000000000000000",
    value: "0x00",
    data: "0x7f7465737432000000000000000000000000000000000000000000000000000000600057",
    chain_id: 3 # EIP 155 chainId - mainnet: 1, ropsten: 3
  }
  @transactions File.read!("test/fixtures/transactions.json") |> Poison.decode!
  @eip155_transactions File.read!("test/fixtures/eip155_vitalik_tests.json") |> Poison.decode!

  test "parse/1 and to_list/1 works for 0x hexed transactions" do
    @transactions
    |> Enum.slice(0..3)
    |> Enum.map(fn(transaction) -> transaction["raw"] end)
    |> Enum.each(fn(transaction) ->
      transaction_list = transaction |> ETH.Transaction.parse |> ETH.Transaction.to_list

      transaction_list
      |> Stream.with_index
      |> Enum.each(fn({value, index}) ->
        encoded_buffer = Enum.at(transaction_list, index) |> Base.encode16(case: :lower)
        assert Enum.at(transaction, index) == "0x#{encoded_buffer}"
      end)
    end)
  end

  test "hash/1 works" do
    target_hash = "DF2A7CB6D05278504959987A144C116DBD11CBDC50D6482C5BAE84A7F41E2113"
    assert @first_example_transaction
      |> ETH.Transaction.to_list
      |> List.insert_at(-1, @first_example_transaction.chain_id)
      |> ETH.Transaction.hash(false)
      |> Base.encode16 == target_hash

    first_transaction_list = @transactions
      |> Enum.at(2)
      |> Map.get("raw")
      |> ETH.Transaction.parse
      |> ETH.Transaction.to_list

    second_transaction_list = @transactions
      |> Enum.at(3)
      |> Map.get("raw")
      |> ETH.Transaction.parse
      |> ETH.Transaction.to_list

    assert ETH.Transaction.hash(first_transaction_list) == decode16("375a8983c9fc56d7cfd118254a80a8d7403d590a6c9e105532b67aca1efb97aa")
    assert ETH.Transaction.hash(first_transaction_list, false) == decode16("61e1ec33764304dddb55348e7883d4437426f44ab3ef65e6da1e025734c03ff0")
    assert ETH.Transaction.hash(first_transaction_list, true) == decode16("375a8983c9fc56d7cfd118254a80a8d7403d590a6c9e105532b67aca1efb97aa")

    assert ETH.Transaction.hash(second_transaction_list) == decode16("0f09dc98ea85b7872f4409131a790b91e7540953992886fc268b7ba5c96820e4")
    assert ETH.Transaction.hash(second_transaction_list, true) == decode16("0f09dc98ea85b7872f4409131a790b91e7540953992886fc268b7ba5c96820e4")
    assert ETH.Transaction.hash(second_transaction_list, false) == decode16("f97c73fdca079da7652dbc61a46cd5aeef804008e057be3e712c43eac389aaf0")
  end

  test "secp256k1_signature/2 works" do
    hash = "5c207a650b59a8c2d1271f5cbda78a658cb411a87271d68062e61ab1a3f85cf9"
      |> Base.decode16!(case: :mixed)
    private_key = "e331b6d69882b4cb4ea581d88e0b604039a3de5967688d3dcffdd2270c0fd109"
      |> Base.decode16!(case: :mixed)

    target_signature = "c2a738b1eb84280399115f4bec9e52b8de494a3ea7d9f069277119a02de4a49876f3168913e968e9484e2e0e447cd7adc56505e25cbc372330793a31f0bf7195"
    secp256k1_signature = ETH.Utils.secp256k1_signature(hash, private_key)

    assert secp256k1_signature[:signature] |> Base.encode16(case: :lower) == target_signature
  end

  test "hash_transaction/2 works" do
    result = @first_example_transaction
      |> ETH.Transaction.hash_transaction(false)
      |> Base.encode16(case: :lower)

    assert result == "df2a7cb6d05278504959987a144c116dbd11cbdc50d6482c5bae84a7f41e2113"
  end

  test "get_sender_address/1 works" do
    transactons = @transactions
    |> Enum.slice(0..2)
    |> Enum.each(fn(transaction) ->
      transaction_list = transaction |> Map.get("raw") |> ETH.Transaction.parse |> ETH.Transaction.to_list

      result = ETH.Transaction.get_sender_address(transaction_list)
      assert result == "0x" <> String.upcase(transaction["sendersAddress"])
    end)
  end

  test "sign/2 works" do
    transactons = @transactions
    |> Enum.slice(0..2)
    |> Enum.each(fn(transaction) ->
      signed_transaction_list = transaction
        |> Map.get("raw")
        |> ETH.Transaction.parse
        |> ETH.Transaction.to_list
        |> ETH.Transaction.sign_transaction_list(transaction["privateKey"])

      result = ETH.Transaction.get_sender_address(signed_transaction_list)
      assert result == "0x" <> String.upcase(transaction["sendersAddress"])
    end)
  end

  test "verify EIP155 Signature based on Vitalik\'s tests" do
    @eip155_transactions |> Enum.each(fn(transaction) ->
      transaction_list = transaction |> Map.get("rlp") |> ETH.Transaction.to_list
      expected_hash = transaction["hash"] |> Base.decode16!(case: :lower)
      assert ETH.Transaction.hash(transaction_list, false) == expected_hash
      sender_address = transaction["sender"] |> String.upcase
      assert ETH.Transaction.get_sender_address(transaction_list) == "0x#{sender_address}"
    end)
  end

  test "send_transaction_works" do
    client_accounts = ETH.Query.get_accounts

    output = ETH.Transaction.set(%{
      nonce: 1, to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5", value: 22, gas_limit: 100000,
      gas_price: 1000, from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
    })
    |> ETH.Transaction.sign_transaction("75c3b11e480f8ba3db792424bebda1fc8dea2b254287e3a9af9ed50c7d255720")
    |> Base.encode16(case: :lower)

    serialized_hash = "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"
    assert output == serialized_hash
  end

  # NOTE: probably not needed changes th API
  # test "can sign an empty transaction with right chain id" do
  #   ETH.Transaction.hash_transaction(%{chain_id: 42 })
  # end

  # test "sign works" do
  #   signature = ETH.Transaction.sign_transaction_list(@first_example_transaction, @first_example_wallet.private_key)
  #     |> Base.encode16(case: :lower)
  #   assert signature == "f889808609184e72a00082271094000000000000000000000000000000000000000080a47f746573743200000000000000000000000000000000000000000000000000000060005729a0f2d54d3399c9bcd3ac3482a5ffaeddfe68e9a805375f626b4f2f8cf530c2d95aa05b3bb54e6e8db52083a9b674e578c843a87c292f0383ddba168573808d36dc8e"
  # end
end
