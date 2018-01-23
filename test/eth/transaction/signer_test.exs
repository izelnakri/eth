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

  # TODO: rewrite the tests below

  test "hash/2 works" do
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

  test "hash_transaction/2 works" do
    result =
      @first_example_transaction
      |> Transaction.hash(false)
      |> Base.encode16(case: :lower)

    assert result == "df2a7cb6d05278504959987a144c116dbd11cbdc50d6482c5bae84a7f41e2113"
  end

  test "sign_transaction/2 works" do
    @transactions
    |> Enum.slice(0..2)
    |> Enum.each(fn transaction ->
      signed_transaction_list =
        transaction
        |> Map.get("raw")
        |> Transaction.parse()
        |> Transaction.to_list()
        |> Transaction.sign_transaction(transaction["privateKey"])

      result = Transaction.get_sender_address(signed_transaction_list)
      assert result == "0x" <> String.upcase(transaction["sendersAddress"])
    end)
  end
end
