require IEx
defmodule ETH.TransactionTest do
  use ExUnit.Case
  import ETH.Utils
  # TODO: "it should decode transactions"

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

  test "sign/2 works" do
    signature = ETH.Transaction.sign(@first_example_transaction, @first_example_wallet.private_key)
      |> Base.encode16(case: :lower)
    assert signature == "f889808609184e72a00082271094000000000000000000000000000000000000000080a47f746573743200000000000000000000000000000000000000000000000000000060005729a0f2d54d3399c9bcd3ac3482a5ffaeddfe68e9a805375f626b4f2f8cf530c2d95aa05b3bb54e6e8db52083a9b674e578c843a87c292f0383ddba168573808d36dc8e"
  end

  # def decode16(value), do: Base.decode16!(value, case: :mixed)
end


# this happens on each setting
# function setter (v) {
#   v = exports.toBuffer(v)
#
#   if (v.toString('hex') === '00' && !field.allowZero) {
#     v = Buffer.allocUnsafe(0)
#   }
#
#   if (field.allowLess && field.length) {
#     v = exports.stripZeros(v)
#     assert(field.length >= v.length, 'The field ' + field.name + ' must not have more ' + field.length + ' bytes')
#   } else if (!(field.allowZero && v.length === 0) && field.length) {
#     assert(field.length === v.length, 'The field ' + field.name + ' must have byte length of ' + field.length)
#   }
#
#   self.raw[i] = v
# }
