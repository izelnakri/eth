require IEx

defmodule TransactionTest do
  use ExUnit.Case
  import ETH.Utils

  setup_all do
    ETH.TestClient.start()

    on_exit(fn ->
      ETH.TestClient.stop()
    end)

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

  test "send_transaction(wallet, params) works" do
    result =
      ETH.send_transaction(@first_wallet_in_client, %{
        to: @first_random_wallet.eth_address,
        value: 22
      })

    {:ok, transaction_hash} = result

    assert result == {:ok, "0x5c1cf004a7d239c65e1ef582826258b7835b0301063605c238947682fe3303d8"}

    Process.sleep(3850)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number]) == %{
             from: "0x051d51ba1e1d58db72efea63549a6792c8f5cb13",
             gas: 21000,
             gas_price: 20_000_000_000,
             hash: "0x5c1cf004a7d239c65e1ef582826258b7835b0301063605c238947682fe3303d8",
             input: "0x0",
             nonce: 0,
             to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
             transaction_index: 0,
             value: 22
           }
  end

  test "send_transaction(params_as_list, private_key) works" do
    result =
      ETH.send_transaction(
        [
          to: @first_random_wallet.eth_address,
          value: 5000
        ],
        @first_wallet_in_client.private_key
      )

    {:ok, transaction_hash} = result

    Process.sleep(3850)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: "0x051d51ba1e1d58db72efea63549a6792c8f5cb13",
               gas: 21000,
               gas_price: 20_000_000_000,
               input: "0x0",
               nonce: 1,
               to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
               transaction_index: 0,
               value: 5000
             }
  end

  test "send_transaction(params_as_map, private_key) works" do
    result =
      ETH.send_transaction(
        %{
          to: @first_random_wallet.eth_address,
          value: 1000,
          data: "Izel Nakri"
        },
        @first_wallet_in_client.private_key
      )

    {:ok, transaction_hash} = result

    Process.sleep(3850)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: "0x051d51ba1e1d58db72efea63549a6792c8f5cb13",
               gas: 21816,
               gas_price: 20_000_000_000,
               input: "0x497a656c204e616b7269",
               nonce: 2,
               to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
               transaction_index: 0,
               value: 1000
             }
  end

  test "send_transaction(sender_wallet, receiver_wallet, value) works" do
    {:ok, tx_hash} = ETH.send_transaction(@first_wallet_in_client, @first_random_wallet, 3200)

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: "0x051d51ba1e1d58db72efea63549a6792c8f5cb13",
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x0",
             nonce: 3,
             to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
             transaction_index: 0,
             value: 3200
           }
  end

  test "send_transaction(sender_wallet, receiver_wallet, params_as_map) works" do
    {:ok, tx_hash} =
      ETH.send_transaction(@first_wallet_in_client, @first_random_wallet, %{
        data: "Sent from eth.ex",
        gas_limit: 40000,
        gas_price: 30_000_000_000,
        value: 5000
      })

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: "0x051d51ba1e1d58db72efea63549a6792c8f5cb13",
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 4,
             to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
             transaction_index: 0,
             value: 5000
           }
  end

  test "send_transaction(sender_wallet, receiver_wallet, params_as_list) works" do
    {:ok, tx_hash} =
      ETH.send_transaction(
        @first_wallet_in_client,
        @first_random_wallet,
        data: "Sent from eth.ex",
        gas_limit: 40000,
        gas_price: 30_000_000_000,
        value: 5000
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: "0x051d51ba1e1d58db72efea63549a6792c8f5cb13",
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 5,
             to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
             transaction_index: 0,
             value: 5000
           }
  end

  # missing:   def send_transaction(sender_wallet, receiver_wallet, params) when is_list(params) do

  # ETH.build(%{
  #   nonce: 1,
  #   to: "0x0dcd857b3c5db88cb7c025f0ef229331cfadffe5",
  #   value: 22,
  #   gas_limit: 100_000,
  #   gas_price: 1000,
  #   from: "0x42c343d8b77a9106d7112b71ba6b3030a34ba560"
  # })
  # |> ETH.sign_transaction(
  #   "75c3b11e480f8ba3db792424bebda1fc8dea2b254287e3a9af9ed50c7d255720"
  # )
  # |> Base.encode16(case: :lower)

  test "send works" do
    result =
      ETH.send(
        "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"
      )

    assert result == {:ok, "0xfa19fa6afd6c5b5ef9979ecf3b437e0b844484cc3a3b6f97082be60799767510"}
  end

  test "send! works" do
    result =
      ETH.send!(
        "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"
      )

    assert result == "0xfa19fa6afd6c5b5ef9979ecf3b437e0b844484cc3a3b6f97082be60799767510"
  end

  # test "send_transaction(wallet, params) works when params is a wallet" do
  #   result = ETH.send_transaction(@first_wallet_in_client, %{
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

  test "get_sender_adress/1 works" do
    @transactions
    |> Enum.slice(0..2)
    |> Enum.each(fn transaction ->
      transaction_list =
        transaction
        |> Map.get("raw")
        |> ETH.parse()
        |> ETH.to_list()

      result = ETH.get_sender_address(transaction_list)
      assert result == "0x" <> String.upcase(transaction["sendersAddress"])
    end)
  end

  test "verify EIP155 Signature based on Vitalik\'s tests" do
    @eip155_transactions
    |> Enum.each(fn transaction ->
      transaction_list = transaction |> Map.get("rlp") |> ETH.to_list()
      expected_hash = transaction["hash"] |> Base.decode16!(case: :lower)
      assert ETH.hash_transaction(transaction_list, false) == expected_hash
      sender_address = transaction["sender"] |> String.upcase()
      assert ETH.get_sender_address(transaction_list) == "0x#{sender_address}"
    end)
  end

  # NOTE: probably not needed changes th API
  # test "can sign an empty transaction with right chain id" do
  #   ETH.hash_transaction(%{chain_id: 42 })
  # end

  # test "sign works" do
  #   signature = ETH.sign_transaction_list(@first_example_transaction, @first_example_wallet.private_key)
  #     |> Base.encode16(case: :lower)
  #   assert signature == "f889808609184e72a00082271094000000000000000000000000000000000000000080a47f746573743200000000000000000000000000000000000000000000000000000060005729a0f2d54d3399c9bcd3ac3482a5ffaeddfe68e9a805375f626b4f2f8cf530c2d95aa05b3bb54e6e8db52083a9b674e578c843a87c292f0383ddba168573808d36dc8e"
  # end
end
