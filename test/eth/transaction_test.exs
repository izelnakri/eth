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

  # TODO: investigate these
  # test "send works" do
  #   result =
  #     ETH.send(
  #       "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"
  #     )

  #   assert result == {:ok, "0xfa19fa6afd6c5b5ef9979ecf3b437e0b844484cc3a3b6f97082be60799767510"}
  # end

  # test "send! works" do
  #   result =
  #     ETH.send!(
  #       "f862018203e8830186a0940dcd857b3c5db88cb7c025f0ef229331cfadffe516801ba09b35467cf48151683b41ed8425d59317716f4f639126d7eb69167ac95c8c3ba3a00d5d21f4c6fc400202dadc09a192b011cc16aefa6155d4e5df15d77d9f6c8f9f"
  #     )

  #   assert result == "0xfa19fa6afd6c5b5ef9979ecf3b437e0b844484cc3a3b6f97082be60799767510"
  # end

  test "send_transaction(wallet, params) works" do
    result =
      ETH.send_transaction(@first_wallet_in_client, %{
        to: @first_random_wallet.eth_address,
        value: 22
      })

    {:ok, transaction_hash} = result

    assert result == {:ok, "0x25cc849e9f13b608f2dcbc75bf227e1c4cb97c77498e6276bb7ed99fe9f8ed4b"}

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             hash: transaction_hash,
             input: "0x",
             nonce: 0,
             to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
             transaction_index: 0,
             value: 22,
             r: "0x6cbe07edff24e20cfd48e52f9abc4f694ad82a30c72e87f60134c08a012b6d3a",
             s: "0x469693e0827d92968510915d31443780fc05553da3216db19f23aed508968d0f",
             v: "0x1c"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21000,
               gas_price: 20_000_000_000,
               input: "0x",
               nonce: 1,
               to: String.downcase(@first_random_wallet.eth_address),
               transaction_index: 0,
               value: 5000,
               r: "0xba634f819eb51d142e98b4e4cac9b7e3858b0a5070e56667e4fc3bfad26b3fdc",
               s: "0x171077b7c1cd3169709c7021594dc5af026b279bc475864982ca66c0453a64ba",
               v: "0x1b"
             }
  end

  # NOTE: this doesnt work because data is a simple string?
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21160,
               gas_price: 20_000_000_000,
               input: "0x497a656c204e616b7269",
               nonce: 2,
               to: String.downcase(@first_random_wallet.eth_address),
               transaction_index: 0,
               value: 1000,
               r: "0xbc4f17432826124d3c3aec92057114ab675bf004638a66a36676604e096a9f30",
               s: "0x1f71f716f90c2a581f4f5b12401c216a3eea780f2ecd5ccd1ecc1264a59126fd",
               v: "0x1c"
             }
  end

  test "send_transaction(sender_wallet, receiver_wallet, value) works" do
    {:ok, tx_hash} = ETH.send_transaction(@first_wallet_in_client, @first_random_wallet, 3200)

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x",
             nonce: 3,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 3200,
             r: "0x7e6a7da26e64c1a2459ddb7a82b3ca41eac5cf0bbc7322cffaff5d24b9b0fac2",
             s: "0x2bf3691c09af831230bac7109b858fcd7eae3866ec2072eba3f71a057507142",
             v: "0x1b"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 4,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 5000,
             r: "0x34033da996d1e2e56a8be710d552d8480662342f0504964ebd02cb687601f2d4",
             s: "0x4ecba3b71eea4d9bf788fa120fd9159e5d9a0ee579dbcdf9f41fb0d23effad55",
             v: "0x1c"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 5,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 5000,
             r: "0x81a2ee3be4c9ba6ead6fc86298fb1f0ff0b3c6bdbbc6fb2c52a1ef1ba5018904",
             s: "0x7ac7b31ebfe580d83c7ef6439acc679453567418f1c9d1364e47db5f6a469eff",
             v: "0x1b"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x",
             nonce: 6,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 10,
             r: "0xb150598cfd7634ce21ef69cb262cbe58a647018c6d834f2fb48b83f60acd4230",
             s: "0x60d199c5d870846ed05a0ce17046cef1a7d0b79e8c26f8bde19213c0f3a7db7e",
             v: "0x1b"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21144,
             gas_price: 20_000_000_000,
             input: "0x4772656174206f6e65",
             nonce: 7,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 1115,
             r: "0xd115972b13b15a9dc3cc06312f7229902c1eba3492caa29d3f881f0fe6a54fd2",
             s: "0x65f9f0a77d9fc56a4b05717228bac8caf3a23d7e7cc3500ec2a41241fffa3e1",
             v: "0x1b"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21144,
             gas_price: 100_000_000_000,
             input: "0x4772656174206f6e65",
             nonce: 8,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 2222,
             r: "0xc0a77eaa7b6383492968ae872f2d9b49b444fe970287b2029bb9f9b2581e0205",
             s: "0x7d8d528cdaf96b81d6c887ed28b7e7024b8529a64aeeb3d9c84c5f1eb06d28f3",
             v: "0x1b"
           }
  end

  test "send_transaction!(wallet, params) works" do
    transaction_hash =
      ETH.send_transaction!(@first_wallet_in_client, %{
        to: @first_random_wallet.eth_address,
        value: 22
      })

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21000,
               gas_price: 20_000_000_000,
               input: "0x",
               nonce: 9,
               to: "0xdf7a2dc05778d1b507e921fb8ad78cb431590ba7",
               transaction_index: 0,
               value: 22,
               r: "0x5024394dfd642ebc7704ca00ddb7523e400ec58d666c9c83018b443294229241",
               s: "0x744d37bf7a119ff28e2eeeb7f568d0def38f950f0cef903a6fb2aaaf620a8878",
               v: "0x1b"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21000,
               gas_price: 20_000_000_000,
               input: "0x",
               nonce: 10,
               to: String.downcase(@first_random_wallet.eth_address),
               transaction_index: 0,
               value: 5000,
               r: "0x2337d3a59ceb0eddfd6e313bc5baee98fa9fc9dd67f109c80376b59dbb270905",
               s: "0x7c64bc07e1887a0630c644aac49c2fd2004dfc64457f69be6f44919a391ad500",
               v: "0x1c"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(transaction_hash) |> Map.drop([:block_hash, :block_number, :hash]) ==
             %{
               from: String.downcase(@first_wallet_in_client.eth_address),
               gas: 21160,
               gas_price: 20_000_000_000,
               input: "0x497a656c204e616b7269",
               nonce: 11,
               to: String.downcase(@first_random_wallet.eth_address),
               transaction_index: 0,
               value: 1000,
               r: "0x2a965620c1d05a35b0ca881071684a1a09626b9d661dc5f005ad582474a5b67",
               s: "0x406eba4ccf0a51184b054ca0d5057fca21830b65d5d09a6d84f606e5cab06e29",
               v: "0x1c"
             }
  end

  test "send_transaction!(sender_wallet, receiver_wallet, value) works" do
    tx_hash = ETH.send_transaction!(@first_wallet_in_client, @first_random_wallet, 3200)

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x",
             nonce: 12,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 3200,
             r: "0xc8dce05282b257e59a9bfbc14b15d6c1a57205781c2f852b30edf784f5dfe10a",
             s: "0x41a8b7dee4aace70044fc4dbad1112e0c42fe7d00e30a315f34cb0df6e494f6",
             v: "0x1b"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 13,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 5000,
             r: "0xdf52efa02f9f3920c8879a5483bfddafe983d91e012b2dc3e58e56ff30d0c6d2",
             s: "0x12901cb5706716c3f28ab1cc27f935dbba708f573bd424fee8339734abab15c4",
             v: "0x1b"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 40000,
             gas_price: 30_000_000_000,
             input: "0x53656e742066726f6d206574682e6578",
             nonce: 14,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 5000,
             r: "0xcc0f43f102c733aab3758bbcf67b5b76f1a5a95473133f9d727e484ef2fbf9b3",
             s: "0x625649625b8024569e5a77bbf305a1c7dd0ff9f01e1ec37fd1ef7ba10d4bf356",
             v: "0x1c"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21000,
             gas_price: 20_000_000_000,
             input: "0x",
             nonce: 15,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 10,
             r: "0x41064d5a172f8eb60a11ff298210d6fde6aa69dbebf9e07bae3a4af42e28aa78",
             s: "0x2631e35057929d093faddbbd1434053f86f0880b8c4676e8cf75fcd6d6bbb0af",
             v: "0x1b"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21144,
             gas_price: 20_000_000_000,
             input: "0x4772656174206f6e65",
             nonce: 16,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 1115,
             r: "0x1ee6a03ffc1a8581e144bf561c61e55ca31c26321cd510fcf48aee7e232b0b50",
             s: "0x56d35093f7424fec6113d78cec8bdc39035e25503a5d090021dcb9fc3a7c2671",
             v: "0x1c"
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

    ETH.TestClient.advance_block_by(1)

    assert ETH.get_transaction!(tx_hash) |> Map.drop([:block_hash, :block_number, :hash]) == %{
             from: String.downcase(@first_wallet_in_client.eth_address),
             gas: 21144,
             gas_price: 20_000_000_000,
             input: "0x4772656174206f6e65",
             nonce: 17,
             to: String.downcase(@first_random_wallet.eth_address),
             transaction_index: 0,
             value: 2222,
             r: "0xd297ac4ad7b35da3c345a6061847ce5bf31e8c8cb98337eb1f76cd037b2a00a0",
             s: "0x74ba2cf121090a71ebf8183515b33e26a2b312e37f7d33def75349f0748b86db",
             v: "0x1c"
           }
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
