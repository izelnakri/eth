require IEx

defmodule TransactionTest do
  use ExUnit.Case
  import ETH.Utils

  alias ETH.Transaction

  setup_all do
    ETH.TestClient.start

    on_exit fn ->
      ETH.TestClient.stop
    end

    :ok
  end

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
