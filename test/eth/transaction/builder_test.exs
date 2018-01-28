defmodule ETH.Transaction.Setter.Test do
  use ExUnit.Case
  import ETH.Utils

  setup_all do
    ETH.TestClient.start()

    on_exit(fn ->
      ETH.TestClient.stop()
    end)

    :ok
  end

  @sender_wallet %{
    eth_address: "0x816307AD84BB5393923BD9D43B71580584F1EBE1",
    mnemonic_phrase:
      "select afraid fatal cost kite prison early doll casual use glory guide guess field inch wasp poet gorilla awkward season bullet tiny mad opinion",
    private_key: "C340914E1857B356114A0523BDF58E33C676ABDC97BCA72C94436111E3C4E16C",
    public_key:
      "043A0E62BB5F40FEAC2B0395B9F529E0AD0AEF4F28EFB9268F69ECADA951371A1DA40C6C6FDC6824DF91D07A664CE18E428CEA068438D7CD01643AE205E99B6CF2"
  }
  @receiver_wallet %{
    eth_address: "0x619C0FA246D04A4B34DBEF7088EA1089B9E16EBD",
    mnemonic_phrase:
      "sister dash elder today shoe before frog boil jungle aerobic echo decide volume crunch clutch drive uniform pave hero negative child claw audit detail",
    private_key: "C986F51D71AC66285748C8790085179C6F5C69CB221AED7431AD49F27E5403C1",
    public_key:
      "047A2E098A3B536F041FF2DEA12EFBD47103E2ACC6AA247ECCD20D5C172F575081017DDF19198A7221AADA56B5F486EFA69C5AA81BAD061FDDCB57E8979DD1BE95"
  }

  test "ETH.build(transaction_list) works when transaction is a list" do
    assert ETH.build(
             nonce: 12,
             gas_price: 10,
             gas_limit: 11,
             to: "0x3535353535353535353535353535353535353535",
             value: 20,
             data: "Elixir is awesome"
           ) == %{
             nonce: to_buffer(12),
             gas_price: to_buffer(10),
             gas_limit: to_buffer(11),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: to_buffer(20),
             data: to_buffer("Elixir is awesome")
           }
  end

  test "ETH.build(transaction_list) works with default values when transaction is a list" do
    assert ETH.build(to: "0x3535353535353535353535353535353535353535") == %{
             nonce: to_buffer(0),
             gas_price: to_buffer(20_000_000_000),
             gas_limit: to_buffer(21000),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: to_buffer(0),
             data: ""
           }
  end

  test "ETH.build(transaction_map) works when params is a transaction map" do
    assert ETH.build(%{
             nonce: 12,
             gas_price: 10,
             gas_limit: 11,
             to: "0x3535353535353535353535353535353535353535",
             value: 20,
             data: "Elixir is awesome"
           }) == %{
             nonce: to_buffer(12),
             gas_price: to_buffer(10),
             gas_limit: to_buffer(11),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: to_buffer(20),
             data: to_buffer("Elixir is awesome")
           }
  end

  test "ETH.build(transaction_map) works with default values when transaction is a map" do
    assert ETH.build(%{
             to: "0x3535353535353535353535353535353535353535"
           }) == %{
             nonce: to_buffer(0),
             gas_price: to_buffer(20_000_000_000),
             gas_limit: to_buffer(21000),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: to_buffer(0),
             data: ""
           }
  end

  test "ETH.build(sender_wallet, receiver_wallet, value) works" do
    assert ETH.build(@sender_wallet, @receiver_wallet, 570) == %{
             nonce: to_buffer(0),
             gas_price: to_buffer(20_000_000_000),
             gas_limit: to_buffer(21000),
             to: to_buffer(@receiver_wallet.eth_address),
             value: to_buffer(570),
             data: ""
           }
  end

  test "ETH.build(sender_wallet, receiver_wallet, transaction_list) works when transaction params is a list" do
    assert ETH.build(
             @sender_wallet,
             @receiver_wallet,
             nonce: 12,
             gas_price: 10,
             gas_limit: 11,
             to: "0x3535353535353535353535353535353535353535",
             value: 20,
             data: "Elixir is awesome"
           ) == %{
             nonce: to_buffer(12),
             gas_price: to_buffer(10),
             gas_limit: to_buffer(11),
             to: to_buffer(@receiver_wallet.eth_address),
             value: to_buffer(20),
             data: to_buffer("Elixir is awesome")
           }
  end

  test "ETH.build(sender_wallet, receiver_wallet, transaction_list) works when transaction params is a list and assigns default values" do
    assert ETH.build(@sender_wallet, @receiver_wallet, value: 660) == %{
             nonce: to_buffer(0),
             gas_price: to_buffer(20_000_000_000),
             gas_limit: to_buffer(21000),
             to: to_buffer(@receiver_wallet.eth_address),
             value: to_buffer(660),
             data: ""
           }
  end

  test "ETH.build(sender_wallet, receiver_wallet, transaction_params) works when transaction params is a map" do
    assert ETH.build(@sender_wallet, @receiver_wallet, %{
             nonce: 12,
             gas_price: 10,
             gas_limit: 11,
             to: "0x3535353535353535353535353535353535353535",
             value: 20,
             data: "Elixir is awesome"
           }) == %{
             nonce: to_buffer(12),
             gas_price: to_buffer(10),
             gas_limit: to_buffer(11),
             to: to_buffer(@receiver_wallet.eth_address),
             value: to_buffer(20),
             data: to_buffer("Elixir is awesome")
           }
  end

  test "Transaction.set(sender_wallet, receiver_wallet, trasnsaction_params) works when transaction params is a map and assigns default values" do
    assert ETH.build(@sender_wallet, @receiver_wallet, %{
             value: 730
           }) == %{
             nonce: to_buffer(0),
             gas_price: to_buffer(20_000_000_000),
             gas_limit: to_buffer(21000),
             to: to_buffer(@receiver_wallet.eth_address),
             value: to_buffer(730),
             data: ""
           }
  end
end
