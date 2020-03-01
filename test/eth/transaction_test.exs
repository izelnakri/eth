# NOTE: FAILING
# NOTE: random wallet cannot send transaction properly?!?
require IEx

defmodule TransactionTest do
  use ExUnit.Case

  setup_all do
    ETH.TestClient.start()

    on_exit(fn ->
      ETH.TestClient.stop()
    end)

    :ok
  end

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
             from: String.downcase(@first_wallet_in_client.eth_address),
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
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21000,
               gas_price: 20_000_000_000,
               input: "0x0",
               nonce: 1,
               to: String.downcase(@first_random_wallet.eth_address),
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
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21816,
               gas_price: 20_000_000_000,
               input: "0x497a656c204e616b7269",
               nonce: 2,
               to: String.downcase(@first_random_wallet.eth_address),
               transaction_index: 0,
               value: 1000
             }
  end

  test "send_transaction(sender_wallet, receiver_wallet, value) works" do
    {:ok, tx_hash} = ETH.send_transaction(@first_wallet_in_client, @first_random_wallet, 3200)

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x0",
             nonce: 3,
             to: String.downcase(@first_random_wallet.eth_address),
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
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 4,
             to: String.downcase(@first_random_wallet.eth_address),
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
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 5,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 5000
           }
  end

  test "send_transaction(sender_wallet, receiver_wallet, value, private_key) works" do
    {:ok, tx_hash} =
      ETH.send_transaction(
        @first_wallet_in_client,
        @first_random_wallet,
        10,
        @first_wallet_in_client.private_key
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x0",
             nonce: 6,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 10
           }
  end

  test "send_transaction(sender_wallet, receiver_wallet, params_as_map, private_key) works" do
    {:ok, tx_hash} =
      ETH.send_transaction(
        @first_wallet_in_client,
        @first_random_wallet,
        %{
          data: "Great one",
          value: 1115
        },
        @first_wallet_in_client.private_key
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21748,
             gas_price: 20_000_000_000,
             input: "0x4772656174206f6e65",
             nonce: 7,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 1115
           }
  end

  test "send_transaction(sender_wallet, receiver_wallet, params_as_list, private_key) works" do
    {:ok, tx_hash} =
      ETH.send_transaction(
        @first_wallet_in_client,
        @first_random_wallet,
        [
          data: "Great one",
          value: 2222,
          gas_price: 100_000_000_000
        ],
        @first_wallet_in_client.private_key
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21748,
             gas_price: 100_000_000_000,
             input: "0x4772656174206f6e65",
             nonce: 8,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 2222
           }
  end

  test "send_transaction!(wallet, params) works" do
    transaction_hash =
      ETH.send_transaction!(@first_wallet_in_client, %{
        to: @first_random_wallet.eth_address,
        value: 22
      })

    Process.sleep(3850)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21000,
               gas_price: 20_000_000_000,
               input: "0x0",
               nonce: 9,
               to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
               transaction_index: 0,
               value: 22
             }
  end

  test "send_transaction!(params_as_list, private_key) works" do
    transaction_hash =
      ETH.send_transaction!(
        [
          to: @first_random_wallet.eth_address,
          value: 5000
        ],
        @first_wallet_in_client.private_key
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21000,
               gas_price: 20_000_000_000,
               input: "0x0",
               nonce: 10,
               to: String.downcase(@first_random_wallet.eth_address),
               transaction_index: 0,
               value: 5000
             }
  end

  test "send_transaction!(params_as_map, private_key) works" do
    transaction_hash =
      ETH.send_transaction!(
        %{
          to: @first_random_wallet.eth_address,
          value: 1000,
          data: "Izel Nakri"
        },
        @first_wallet_in_client.private_key
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21816,
               gas_price: 20_000_000_000,
               input: "0x497a656c204e616b7269",
               nonce: 11,
               to: String.downcase(@first_random_wallet.eth_address),
               transaction_index: 0,
               value: 1000
             }
  end

  test "send_transaction!(sender_wallet, receiver_wallet, value) works" do
    tx_hash = ETH.send_transaction!(@first_wallet_in_client, @first_random_wallet, 3200)

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x0",
             nonce: 12,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 3200
           }
  end

  test "send_transaction!(sender_wallet, receiver_wallet, params_as_map) works" do
    tx_hash =
      ETH.send_transaction!(@first_wallet_in_client, @first_random_wallet, %{
        data: "Sent from eth.ex",
        gas_limit: 40000,
        gas_price: 30_000_000_000,
        value: 5000
      })

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 13,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 5000
           }
  end

  test "send_transaction!(sender_wallet, receiver_wallet, params_as_list) works" do
    tx_hash =
      ETH.send_transaction!(
        @first_wallet_in_client,
        @first_random_wallet,
        data: "Sent from eth.ex",
        gas_limit: 40000,
        gas_price: 30_000_000_000,
        value: 5000
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 14,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 5000
           }
  end

  test "send_transaction!(sender_wallet, receiver_wallet, value, private_key) works" do
    tx_hash =
      ETH.send_transaction!(
        @first_wallet_in_client,
        @first_random_wallet,
        10,
        @first_wallet_in_client.private_key
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x0",
             nonce: 15,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 10
           }
  end

  test "send_transaction!(sender_wallet, receiver_wallet, params_as_map, private_key) works" do
    tx_hash =
      ETH.send_transaction!(
        @first_wallet_in_client,
        @first_random_wallet,
        %{
          data: "Great one",
          value: 1115
        },
        @first_wallet_in_client.private_key
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21748,
             gas_price: 20_000_000_000,
             input: "0x4772656174206f6e65",
             nonce: 16,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 1115
           }
  end

  test "send_transaction!(sender_wallet, receiver_wallet, params_as_list, private_key) works" do
    tx_hash =
      ETH.send_transaction!(
        @first_wallet_in_client,
        @first_random_wallet,
        [
          data: "Great one",
          value: 2222,
          gas_price: 20_000_000_000
        ],
        @first_wallet_in_client.private_key
      )

    Process.sleep(3850)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21748,
             gas_price: 20_000_000_000,
             input: "0x4772656174206f6e65",
             nonce: 17,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 2222
           }
  end

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

  test "get_sender_public_key(rlp_encoded_transaction) works" do
    @transactions
    |> Enum.each(fn transaction ->
      private_key = Map.get(transaction, "privateKey")

      if private_key do
        target_public_key = ETH.Wallet.create(private_key) |> Map.get(:public_key)

        encoded_rlp =
          Map.get(transaction, "raw")
          |> ETH.parse()
          |> ETH.to_list()
          |> ExRLP.encode()
          |> Base.encode16()

        assert ETH.get_senders_public_key("0x" <> encoded_rlp) ==
                 target_public_key |> Base.decode16!()
      end
    end)
  end

  test "get_sender_public_key(signed_transaction_list) works" do
    @transactions
    |> Enum.each(fn transaction ->
      private_key = Map.get(transaction, "privateKey")

      if private_key do
        target_public_key = ETH.Wallet.create(private_key) |> Map.get(:public_key)

        assert Map.get(transaction, "raw")
               |> ETH.Transaction.parse()
               |> ETH.Transaction.to_list()
               |> ETH.get_senders_public_key() == target_public_key |> Base.decode16!()
      end
    end)
  end

  test "get_sender_address(rlp_encoded_transaction) works" do
    @eip155_transactions
    |> Enum.each(fn transaction ->
      sender_address = "0x" <> (transaction |> Map.get("sender") |> String.upcase())

      assert transaction |> Map.get("rlp") |> ETH.get_sender_address() == sender_address
    end)
  end

  test "get_sender_adress(signed_transaction_list) works" do
    @transactions
    |> Enum.slice(0..2)
    |> Enum.each(fn transaction ->
      transaction_list =
        transaction
        |> Map.get("raw")
        |> ETH.parse()
        |> ETH.to_list()

      sender_address = "0x" <> String.upcase(transaction["sendersAddress"])

      assert ETH.get_sender_address(transaction_list) == sender_address
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
end
