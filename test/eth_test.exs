# NOTE: FAILING
defmodule ETHTest do
  use ExUnit.Case

  # @first_transaction_list [
  #   "", "09184e72a000", "2710", "0000000000000000000000000000000000000000", "",
  #   "7f7465737432000000000000000000000000000000000000000000000000000000600057", "29",
  #   "f2d54d3399c9bcd3ac3482a5ffaeddfe68e9a805375f626b4f2f8cf530c2d95a",
  #   "5b3bb54e6e8db52083a9b674e578c843a87c292f0383ddba168573808d36dc8e"
  # ] |> Enum.map(fn(x) -> Base.decode16!(x, case: :lower) end)

  # @first_example_wallet %{
  #   private_key: "e331b6d69882b4cb4ea581d88e0b604039a3de5967688d3dcffdd2270c0fd109"
  # }
  # @first_example_transaction %{
  #   nonce: "",
  #   gas_price: "09184e72a000",
  #   gas_limit: "2710",
  #   to: "0000000000000000000000000000000000000000",
  #   value: "",
  #   data: "7f7465737432000000000000000000000000000000000000000000000000000000600057",
  #   chain_id: 3 # EIP 155 chainId - mainnet: 1, ropsten: 3
  # }


  # test "hash/1 works" do
  #   target_hash = "5C207A650B59A8C2D1271F5CBDA78A658CB411A87271D68062E61AB1A3F85CF9"
  #   assert ETH.Transaction.hash_transaction(@first_transaction_list) |> Base.encode16 == target_hash
  # end

  # test "secp256k1_signature/2 works" do
  #   hash = "5c207a650b59a8c2d1271f5cbda78a658cb411a87271d68062e61ab1a3f85cf9"
  #     |> Base.decode16!(case: :mixed)
  #   private_key = "e331b6d69882b4cb4ea581d88e0b604039a3de5967688d3dcffdd2270c0fd109"
  #     |> Base.decode16!(case: :mixed)

  #   target_signature = "c2a738b1eb84280399115f4bec9e52b8de494a3ea7d9f069277119a02de4a49876f3168913e968e9484e2e0e447cd7adc56505e25cbc372330793a31f0bf7195"
  #   secp256k1_signature = ETH.Utils.secp256k1_signature(hash, private_key)

  #   assert secp256k1_signature[:signature] |> Base.encode16(case: :lower) == target_signature
  # end

  # test "hash_transaction/2 works" do
  #   result = ETH.Transaction.hash_transaction(@first_example_transaction) |> Base.encode16(case: :lower)
  #   target_digest = "df2a7cb6d05278504959987a144c116dbd11cbdc50d6482c5bae84a7f41e2113"
  #   assert result == target_digest
  # end

  # test "sign_transaction/2 works" do
  #   signature = ETH.Transaction.sign_transaction(@first_example_transaction, @first_example_wallet.private_key)
  #     |> Base.encode16(case: :lower)

  #   assert signature == "f889808609184e72a00082271094000000000000000000000000000000000000000080a47f746573743200000000000000000000000000000000000000000000000000000060005729a0f2d54d3399c9bcd3ac3482a5ffaeddfe68e9a805375f626b4f2f8cf530c2d95aa05b3bb54e6e8db52083a9b674e578c843a87c292f0383ddba168573808d36dc8e"
  # end
end
