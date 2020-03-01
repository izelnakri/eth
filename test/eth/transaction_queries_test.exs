# NOTE: FAILING
defmodule ETH.TransactionQueries.Test do
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
  @second_wallet_in_client %{
    eth_address: "0x1800542A82E6DE47CF4D310305F56EE56F63024A",
    mnemonic_phrase:
      "dignity adapt fat fury require fury federal crystal hero account art link fancy peace infant endless journey crane prepare topple visual walk owner arrive",
    private_key: "3e00614daf3b70bcd519aa6b40303341052f439cd24d78664aa7f29f4fed2788",
    public_key:
      "048D505C1C871C1A04B8970789CAD4EC70BB302470F3EDE2D32A3D27EE25EB4B827CEE264A268A02D9D6153BFDBCF290DA1C5130523B35BF8D964050688A909770"
  }
  @third_wallet_in_client %{
    eth_address: "0xC8FDF0764E2F783B11B6A2552A78CE14B2CEB484",
    mnemonic_phrase:
      "loop right hungry only east task humble panel canvas hunt plastic rival page discover omit crisp item when region pencil burden diagram nice nurse",
    private_key: "83f739bd4d845bbc1bbcfc21adee985d59ee7de6999d76df46d25151e879e55c",
    public_key:
      "041D42B37794DA909A9A8C1A2A9EAB6679FE0478383F9FFC212EACDF7B7B844B1E0E7D2F74840DD173141B41AB02B6E01AB0B85D330DBE9D398ECE35C967D230A1"
  }
  @fourth_wallet_in_client %{
    eth_address: "0x8E4E0A1E2D128EE71EFA14000A9D25A0DFD57426",
    mnemonic_phrase:
      "whisper organ connect honey demise rose gas bronze soul kangaroo word canvas skate arrange cream broccoli pumpkin post mention aware guilt crane idea stand",
    private_key: "fa938cbcb693a5781800e5cfaf33f590dca0188cb8e3adb5162c08267a649c1e",
    public_key:
      "042F65C8522D43CF527A2CFDA9FD15031B835359EB754D32CFCE7447A4FF4928B39B543571E5286FF564D4C8CDD1F8F3D8F928E505CA3D33D02A6917F09A4FC758"
  }
  @fifth_wallet_in_client %{
    eth_address: "0xC2AFEFA6B827CD41AC598086BCF45C5AE7061BFE",
    mnemonic_phrase:
      "lend network mansion huge october bid sister unlock reform husband offer maze inspire frown bitter escape remember talent goat receive capital they choice century",
    private_key: "7ff29a1d3759902c326770b44dfe65c4c754bb05b268b5bbad9059c221c10a09",
    public_key:
      "04F6851EC9A15E389D4D8632DEC890429B9F50038CBECD6013210DD815220826C95D065083810FFE55A32EAF93E4AD79E485C4B334F065A1C759FB76169CABC238"
  }
  @sixth_wallet_in_client %{
    eth_address: "0xE484D305ED89AAA63FDA68B302547C03F3B479D3",
    mnemonic_phrase:
      "phrase civil level wine run method tree suspect jeans economy tuition draw safe orchard front message tree cart powder calm term defy fit jazz",
    private_key: "a3c53202fdcbd51879fed677a8c7a8a13be13817545fe7e462a4904df67355f3",
    public_key:
      "04CEA850A30D36321B0F5409219B6D228E98C57297BF8655ADF4AF407D48787224102CE8A4FBD6BA2C6A28E7419158BBCFD5FF1BA8EF05D1FE2B19518F059F3968"
  }

  # TODO: add some logs in future
  test "get_block_transactions(block_no) works" do
    {:ok, first_block_transactions_by_number} = ETH.get_block_transactions(1)

    assert first_block_transactions_by_number == []

    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    assert ETH.get_block_transactions(ETH.block_number!() - 1) ==
             {:ok,
              [
                ETH.get_transaction!(first_tx_hash),
                ETH.get_transaction!(second_tx_hash)
              ]}
  end

  test "get_block_transactions(block_hash) works" do
    {:ok, first_block_transactions_by_number} = ETH.get_block_transactions(ETH.get_block!(1).hash)

    assert first_block_transactions_by_number == []

    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    target_block = ETH.get_block!(ETH.block_number!() - 1)

    assert ETH.get_block_transactions(target_block.hash) ==
             {:ok,
              [
                ETH.get_transaction!(first_tx_hash),
                ETH.get_transaction!(second_tx_hash)
              ]}
  end

  test "get_block_transactions!(block_no) works" do
    assert ETH.get_block_transactions!(1) == []

    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    assert ETH.get_block_transactions!(ETH.block_number!() - 1) == [
             ETH.get_transaction!(first_tx_hash),
             ETH.get_transaction!(second_tx_hash)
           ]
  end

  test "get_block_transactions!(block_hash) works" do
    assert ETH.get_block_transactions!(ETH.get_block!(1).hash) == []

    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    target_block = ETH.get_block!(ETH.block_number!() - 1)

    assert ETH.get_block_transactions!(target_block.hash) == [
             ETH.get_transaction!(first_tx_hash),
             ETH.get_transaction!(second_tx_hash)
           ]
  end

  test "get_block_transaction_count(block_number)" do
    assert ETH.get_block_transaction_count(1) == {:ok, 0}

    ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)
    ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    assert ETH.get_block_transaction_count(ETH.block_number!() - 1) == {:ok, 2}
  end

  test "get_block_transaction_count!(block_number)" do
    assert ETH.get_block_transaction_count!(1) == 0

    ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)
    ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    assert ETH.get_block_transaction_count!(ETH.block_number!() - 1) == 2
  end

  test "get_block_transaction_count(block_hash) works" do
    assert ETH.get_block_transaction_count(ETH.get_block!(1).hash) == {:ok, 0}

    ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)
    ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    target_block = ETH.get_block!(ETH.block_number!() - 1)

    assert ETH.get_block_transaction_count(target_block.hash) == {:ok, 2}
  end

  test "get_block_transaction_count!(block_hash) works" do
    assert ETH.get_block_transaction_count!(ETH.get_block!(1).hash) == 0

    ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)
    ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    target_block = ETH.get_block!(ETH.block_number!() - 1)

    assert ETH.get_block_transaction_count!(target_block.hash) == 2
  end

  test "get_transaction_from_block(block_number, index) works" do
    assert ETH.get_transaction_from_block(0, 0) |> elem(0) == :error

    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    block_no = ETH.block_number!() - 1

    assert ETH.get_transaction_from_block(block_no, 0) ==
             {:ok, ETH.get_transaction!(first_tx_hash)}

    assert ETH.get_transaction_from_block(block_no, 1) ==
             {:ok, ETH.get_transaction!(second_tx_hash)}

    assert ETH.get_transaction_from_block(block_no, 2) |> elem(0) == :error
  end

  test "get_transaction_from_block!(block_number, index) works" do
    assert_raise MatchError, fn -> ETH.get_transaction_from_block!(0, 0) end

    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    block_no = ETH.block_number!() - 1

    assert ETH.get_transaction_from_block!(block_no, 0) == ETH.get_transaction!(first_tx_hash)
    assert ETH.get_transaction_from_block!(block_no, 1) == ETH.get_transaction!(second_tx_hash)
    assert_raise MatchError, fn -> ETH.get_transaction_from_block!(block_no, 2) |> elem(0) end
  end

  test "get_transaction_from_block(block_hash, index) works" do
    first_block_hash = ETH.get_block!(0).hash
    assert ETH.get_transaction_from_block(first_block_hash, 0) |> elem(0) == :error

    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    block_hash = ETH.get_block!(ETH.block_number!() - 1).hash

    assert ETH.get_transaction_from_block(block_hash, 0) ==
             {:ok, ETH.get_transaction!(first_tx_hash)}

    assert ETH.get_transaction_from_block(block_hash, 1) ==
             {:ok, ETH.get_transaction!(second_tx_hash)}

    assert ETH.get_transaction_from_block(block_hash, 2) |> elem(0) == :error
  end

  test "get_transaction_from_block!(block_hash, index) works" do
    first_block_hash = ETH.get_block!(0).hash

    assert_raise MatchError, fn -> ETH.get_transaction_from_block!(first_block_hash, 0) end

    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    block_hash = ETH.get_block!(ETH.block_number!() - 1).hash

    assert ETH.get_transaction_from_block!(block_hash, 0) == ETH.get_transaction!(first_tx_hash)
    assert ETH.get_transaction_from_block!(block_hash, 1) == ETH.get_transaction!(second_tx_hash)
    assert_raise MatchError, fn -> ETH.get_transaction_from_block!(block_hash, 2) |> elem(0) end
  end

  test "get_transaction(transaction_hash) works" do
    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    {:ok, first_transaction} = ETH.get_transaction(first_tx_hash)
    {:ok, second_transaction} = ETH.get_transaction(second_tx_hash)

    assert Map.keys(first_transaction) == [
             :block_hash,
             :block_number,
             :from,
             :gas,
             :gas_price,
             :hash,
             :input,
             :nonce,
             :to,
             :transaction_index,
             :value
           ]

    assert first_transaction.hash == first_tx_hash

    assert Map.keys(second_transaction) == [
             :block_hash,
             :block_number,
             :from,
             :gas,
             :gas_price,
             :hash,
             :input,
             :nonce,
             :to,
             :transaction_index,
             :value
           ]

    assert second_transaction.hash == second_tx_hash
  end

  test "get_transaction!(transaction_hash) works" do
    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    first_transaction = ETH.get_transaction!(first_tx_hash)
    second_transaction = ETH.get_transaction!(second_tx_hash)

    assert Map.keys(first_transaction) == [
             :block_hash,
             :block_number,
             :from,
             :gas,
             :gas_price,
             :hash,
             :input,
             :nonce,
             :to,
             :transaction_index,
             :value
           ]

    assert first_transaction.hash == first_tx_hash

    assert Map.keys(second_transaction) == [
             :block_hash,
             :block_number,
             :from,
             :gas,
             :gas_price,
             :hash,
             :input,
             :nonce,
             :to,
             :transaction_index,
             :value
           ]

    assert second_transaction.hash == second_tx_hash
  end

  test "get_transaction_receipt(transaction_hash) works" do
    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    {:ok, first_transaction_receipt} = ETH.get_transaction_receipt(first_tx_hash)
    {:ok, second_transaction_receipt} = ETH.get_transaction_receipt(second_tx_hash)

    assert Map.keys(first_transaction_receipt) == [
             :block_hash,
             :block_number,
             :contract_address,
             :cumulative_gas_used,
             :gas_used,
             :logs,
             :status,
             :transaction_hash,
             :transaction_index
           ]

    assert first_transaction_receipt.transaction_hash == first_tx_hash

    assert Map.keys(second_transaction_receipt) == [
             :block_hash,
             :block_number,
             :contract_address,
             :cumulative_gas_used,
             :gas_used,
             :logs,
             :status,
             :transaction_hash,
             :transaction_index
           ]

    assert second_transaction_receipt.transaction_hash == second_tx_hash
  end

  test "get_transaction_receipt!(transaction_hash) works" do
    first_tx_hash = ETH.send_transaction!(@first_wallet_in_client, @second_wallet_in_client, 500)

    second_tx_hash =
      ETH.send_transaction!(@second_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    first_transaction_receipt = ETH.get_transaction_receipt!(first_tx_hash)
    second_transaction_receipt = ETH.get_transaction_receipt!(second_tx_hash)

    assert Map.keys(first_transaction_receipt) == [
             :block_hash,
             :block_number,
             :contract_address,
             :cumulative_gas_used,
             :gas_used,
             :logs,
             :status,
             :transaction_hash,
             :transaction_index
           ]

    assert first_transaction_receipt.transaction_hash == first_tx_hash

    assert Map.keys(second_transaction_receipt) == [
             :block_hash,
             :block_number,
             :contract_address,
             :cumulative_gas_used,
             :gas_used,
             :logs,
             :status,
             :transaction_hash,
             :transaction_index
           ]

    assert second_transaction_receipt.transaction_hash == second_tx_hash
  end

  test "get_transaction_count(wallet) works" do
    assert ETH.get_transaction_count(@third_wallet_in_client) == {:ok, 0}

    ETH.send_transaction!(@third_wallet_in_client, @second_wallet_in_client, 500)

    Process.sleep(2000)

    ETH.send_transaction!(@third_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    assert ETH.get_transaction_count(@third_wallet_in_client, "latest") == {:ok, 2}
  end

  test "get_transaction_count!(wallet) works" do
    assert ETH.get_transaction_count!(@fourth_wallet_in_client) == 0

    ETH.send_transaction!(@fourth_wallet_in_client, @second_wallet_in_client, 500)

    Process.sleep(2000)

    ETH.send_transaction!(@fourth_wallet_in_client, @first_wallet_in_client, 2000)

    Process.sleep(2000)

    assert ETH.get_transaction_count!(@fourth_wallet_in_client, "latest") == 2
  end

  test "get_transaction_count(eth_address) works" do
    assert ETH.get_transaction_count(@fifth_wallet_in_client.eth_address, "latest") == {:ok, 0}

    ETH.send_transaction!(@fifth_wallet_in_client, @second_wallet_in_client, 500)

    Process.sleep(2000)

    ETH.send_transaction!(@fifth_wallet_in_client, @third_wallet_in_client, 2000)

    Process.sleep(2000)

    assert ETH.get_transaction_count(@fifth_wallet_in_client.eth_address) == {:ok, 2}
  end

  test "get_transaction_count!(eth_address) works" do
    assert ETH.get_transaction_count!(@sixth_wallet_in_client.eth_address) == 0

    ETH.send_transaction!(@sixth_wallet_in_client, @second_wallet_in_client, 500)

    Process.sleep(2000)

    ETH.send_transaction!(@sixth_wallet_in_client, @third_wallet_in_client, 2000)

    Process.sleep(2000)

    assert ETH.get_transaction_count!(@sixth_wallet_in_client.eth_address) == 2
  end
end
