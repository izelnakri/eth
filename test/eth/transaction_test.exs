require IEx

defmodule TransactionTest do
  use ExUnit.Case
  import ETH.Utils

  alias ETH.Transaction

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
  @first_wallet_in_client %{
    eth_address: "0x051D51BA1E1D58DB72EFEA63549A6792C8F5CB13",
    mnemonic_phrase:
      "pause action enrich describe found panda world tenant one icon arrange balance soccer field hurdle midnight elite ski inquiry exit section globe raise brass",
    private_key: "a160512c1dc5c33eff6ef89aae083108dcdcabdbe463481949d327fc2ac6ac48",
    public_key:
      "04418C292B1E69D5B49A0F2CA082DF83C361401C8A752C62F1081B6E4935948619779105D12AE05BFD1DE368F66133357FC46F2949899E3BD7F90873384C4F3998"
  }
  @first_random_wallet %{
    eth_address: "0xDF7A2DC05778D1B507E921FB8AD78CB431590BA7",
    mnemonic_phrase:
      "thing photo gate taste task rival method suggest spoon aunt right suit exercise reject quality solve trip race orange fun come oxygen neutral wear",
    private_key: "E0B475816F1DE175630EC7D281EAE76C84F569EBCE77E8D60E6F2F02E13CA53F",
    public_key:
      "04ED16474776479C8AA25539CA1AB4C2A313C5894E55F5204B7982E9F492841B12AEFBB9F75836543EAD8677EE9F2A804DDAB850A9325BF0DB4311A5288F594E8C"
  }

  @transactions File.read!("test/fixtures/transactions.json") |> Poison.decode!()
  @eip155_transactions File.read!("test/fixtures/eip155_vitalik_tests.json") |> Poison.decode!()

  test "parse/1 and to_list/1 works for 0x hexed transactions" do
    @transactions
    |> Enum.slice(0..3)
    |> Enum.map(fn transaction -> transaction["raw"] end)
    |> Enum.each(fn transaction ->
      transaction_list = transaction |> Transaction.parse() |> Transaction.to_list()

      transaction_list
      |> Stream.with_index()
      |> Enum.each(fn {_value, index} ->
        encoded_buffer = Enum.at(transaction_list, index) |> Base.encode16(case: :lower)
        assert Enum.at(transaction, index) == "0x#{encoded_buffer}"
      end)
    end)
  end

  test "hash/1 works" do
    target_hash = "DF2A7CB6D05278504959987A144C116DBD11CBDC50D6482C5BAE84A7F41E2113"

    assert @first_example_transaction
           |> Transaction.to_list()
           |> List.insert_at(-1, @first_example_transaction.chain_id)
           |> Transaction.hash(false)
           |> Base.encode16() == target_hash

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

  test "secp256k1_signature/2 works" do
    hash =
      "5c207a650b59a8c2d1271f5cbda78a658cb411a87271d68062e61ab1a3f85cf9"
      |> Base.decode16!(case: :mixed)

    private_key =
      "e331b6d69882b4cb4ea581d88e0b604039a3de5967688d3dcffdd2270c0fd109"
      |> Base.decode16!(case: :mixed)

    target_signature =
      "c2a738b1eb84280399115f4bec9e52b8de494a3ea7d9f069277119a02de4a49876f3168913e968e9484e2e0e447cd7adc56505e25cbc372330793a31f0bf7195"

    secp256k1_signature = ETH.Utils.secp256k1_signature(hash, private_key)

    assert secp256k1_signature[:signature] |> Base.encode16(case: :lower) == target_signature
  end

  test "hash_transaction/2 works" do
    result =
      @first_example_transaction
      |> Transaction.hash(false)
      |> Base.encode16(case: :lower)

    assert result == "df2a7cb6d05278504959987a144c116dbd11cbdc50d6482c5bae84a7f41e2113"
  end

  # test "send_transaction(wallet, params) works when params is a wallet" do
  #   result = Transaction.send_transaction(@first_wallet_in_client, %{
  #     to: @first_random_wallet.eth_address,
  #     value: 300,
  #     data: ""
  #   })
  #
  #   # IEx.pry
  #   # do various variable sends ->
  # end
  # TODO: DO all types of send_transaction methods

  # TODO: test send() works

  # TODO: get_senders_public_key works on all variations

  # TODO: get_sender_address works on all variations

  test "get_sender_address/1 works" do
    @transactions
    |> Enum.slice(0..2)
    |> Enum.each(fn transaction ->
      transaction_list =
        transaction |> Map.get("raw") |> Transaction.parse() |> Transaction.to_list()

      result = Transaction.get_sender_address(transaction_list)
      assert result == "0x" <> String.upcase(transaction["sendersAddress"])
    end)
  end

  test "sign/2 works" do
    @transactions
    |> Enum.slice(0..2)
    |> Enum.each(fn transaction ->
      signed_transaction_list =
        transaction
        |> Map.get("raw")
        |> Transaction.parse()
        |> Transaction.to_list()
        |> Transaction.sign_transaction_list(transaction["privateKey"])

      result = Transaction.get_sender_address(signed_transaction_list)
      assert result == "0x" <> String.upcase(transaction["sendersAddress"])
    end)
  end

  test "verify EIP155 Signature based on Vitalik\'s tests" do
    @eip155_transactions
    |> Enum.each(fn transaction ->
      transaction_list = transaction |> Map.get("rlp") |> Transaction.to_list()
      expected_hash = transaction["hash"] |> Base.decode16!(case: :lower)
      assert Transaction.hash(transaction_list, false) == expected_hash
      sender_address = transaction["sender"] |> String.upcase()
      assert Transaction.get_sender_address(transaction_list) == "0x#{sender_address}"
    end)
  end

  # NOTE: this should probably go somewhere else
  test "send_transaction_works" do
    output =
      Transaction.build(%{
        nonce: 1,
        to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
        value: 22,
        gas_limit: 100_000,
        gas_price: 1000,
        from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
      })
      |> Transaction.sign_transaction(
        "75c3b11e480f8ba3db792424bebda1fc8dea2b254287e3a9af9ed50c7d255720"
      )
      |> Base.encode16(case: :lower)

    serialized_hash =
      "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"

    assert output == serialized_hash
  end

  # NOTE: probably not needed changes th API
  # test "can sign an empty transaction with right chain id" do
  #   Transaction.hash_transaction(%{chain_id: 42 })
  # end

  # test "sign works" do
  #   signature = Transaction.sign_transaction_list(@first_example_transaction, @first_example_wallet.private_key)
  #     |> Base.encode16(case: :lower)
  #   assert signature == "f889808609184e72a00082271094000000000000000000000000000000000000000080a47f746573743200000000000000000000000000000000000000000000000000000060005729a0f2d54d3399c9bcd3ac3482a5ffaeddfe68e9a805375f626b4f2f8cf530c2d95aa05b3bb54e6e8db52083a9b674e578c843a87c292f0383ddba168573808d36dc8e"
  # end
end
