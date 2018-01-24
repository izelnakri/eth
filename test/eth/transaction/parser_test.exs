defmodule ETH.Transaction.Parser.Test do
  use ExUnit.Case
  import ETH.Utils

  alias ETH.Transaction

  @transactions File.read!("test/fixtures/transactions.json") |> Poison.decode!()
  @first_transaction_rlp "0xf864808504a817c800825208943535353535353535353535353535353535353535808025a0044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116da0044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"
  @not_signed_transaction_list [
    "",
    "0x04a817c800",
    "0x5208",
    "0x3535353535353535353535353535353535353535",
    "",
    ""
  ]
  @signed_transaction_list [
    "",
    "0x04a817c800",
    "0x5208",
    "0x3535353535353535353535353535353535353535",
    "",
    "",
    "0x25",
    "0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d",
    "0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"
  ]
  @not_signed_transaction_map %{
    nonce: "",
    gas_price: "0x04a817c800",
    gas_limit: "0x5208",
    to: "0x3535353535353535353535353535353535353535",
    value: "",
    data: ""
  }
  @signed_transaction_map %{
    nonce: "",
    gas_price: "0x04a817c800",
    gas_limit: "0x5208",
    to: "0x3535353535353535353535353535353535353535",
    value: "",
    data: "",
    v: "0x25",
    r: "0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d",
    s: "0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"
  }

  test "parsing encoded transaction rlp returns a transaction map" do
    assert Transaction.parse(@first_transaction_rlp) == %{
             data: "",
             gas_limit: to_buffer("0x5208"),
             gas_price: to_buffer("0x04a817c800"),
             nonce: "",
             r: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             s: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             v: to_buffer("0x25"),
             value: ""
           }
  end

  test "parsing a not-signed transaction list returns a transaction map" do
    assert Transaction.parse(@not_signed_transaction_list) == %{
             nonce: "",
             gas_price: to_buffer("0x04a817c800"),
             gas_limit: to_buffer("0x5208"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: "",
             data: ""
           }

    buffered_transaction_list =
      @not_signed_transaction_list
      |> Enum.map(fn item -> to_buffer(item) end)

    assert buffered_transaction_list |> Transaction.parse() == %{
             nonce: "",
             gas_price: to_buffer("0x04a817c800"),
             gas_limit: to_buffer("0x5208"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: "",
             data: ""
           }
  end

  test "parsing a signed transaction list returns a transaction map" do
    assert Transaction.parse(@signed_transaction_list) == %{
             nonce: "",
             gas_price: to_buffer("0x04a817c800"),
             gas_limit: to_buffer("0x5208"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: "",
             data: "",
             v: to_buffer("0x25"),
             r: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             s: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d")
           }

    buffered_transaction_list =
      @signed_transaction_list
      |> Enum.map(fn item -> to_buffer(item) end)

    assert buffered_transaction_list |> Transaction.parse() == %{
             nonce: "",
             gas_price: to_buffer("0x04a817c800"),
             gas_limit: to_buffer("0x5208"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: "",
             data: "",
             v: to_buffer("0x25"),
             r: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             s: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d")
           }
  end

  test "parsing a not-signed transaction map returns a buffered transaction map" do
    assert Transaction.parse(@not_signed_transaction_map) == %{
             nonce: "",
             gas_price: to_buffer("0x04a817c800"),
             gas_limit: to_buffer("0x5208"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: "",
             data: ""
           }

    assert Transaction.parse(
             @not_signed_transaction_map |> Map.keys()
             |> Enum.reduce(%{}, fn key, acc ->
               Map.put(acc, key, to_buffer(Map.get(@not_signed_transaction_map, key)))
             end)
           ) == %{
             nonce: "",
             gas_price: to_buffer("0x04a817c800"),
             gas_limit: to_buffer("0x5208"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: "",
             data: ""
           }
  end

  test "parsing a signed transaction map returns a buffered transaction map" do
    assert Transaction.parse(@signed_transaction_map) == %{
             nonce: "",
             gas_price: to_buffer("0x04a817c800"),
             gas_limit: to_buffer("0x5208"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: "",
             data: "",
             v: to_buffer("0x25"),
             r: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             s: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d")
           }

    assert Transaction.parse(
             @signed_transaction_map |> Map.keys()
             |> Enum.reduce(%{}, fn key, acc ->
               Map.put(acc, key, to_buffer(Map.get(@signed_transaction_map, key)))
             end)
           ) == %{
             nonce: "",
             gas_price: to_buffer("0x04a817c800"),
             gas_limit: to_buffer("0x5208"),
             to: to_buffer("0x3535353535353535353535353535353535353535"),
             value: "",
             data: "",
             v: to_buffer("0x25"),
             r: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             s: to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d")
           }
  end

  test "to_list works for encoded rlp transactions" do
    assert Transaction.to_list(@first_transaction_rlp) == [
             "",
             to_buffer("0x04a817c800"),
             to_buffer("0x5208"),
             to_buffer("0x3535353535353535353535353535353535353535"),
             "",
             "",
             to_buffer("0x25"),
             to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d")
           ]
  end

  test "to_list works for signed transactions" do
    assert Transaction.to_list(@signed_transaction_map) == [
             "",
             to_buffer("0x04a817c800"),
             to_buffer("0x5208"),
             to_buffer("0x3535353535353535353535353535353535353535"),
             "",
             "",
             to_buffer("0x25"),
             to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d")
           ]

    assert Transaction.to_list(
             @signed_transaction_map |> Map.keys()
             |> Enum.reduce(%{}, fn key, acc ->
               Map.put(acc, key, to_buffer(Map.get(@signed_transaction_map, key)))
             end)
           ) == [
             "",
             to_buffer("0x04a817c800"),
             to_buffer("0x5208"),
             to_buffer("0x3535353535353535353535353535353535353535"),
             "",
             "",
             to_buffer("0x25"),
             to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"),
             to_buffer("0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d")
           ]
  end

  test "to_list works for not-signed transactions" do
    assert Transaction.to_list(@not_signed_transaction_map) == [
             "",
             to_buffer("0x04a817c800"),
             to_buffer("0x5208"),
             to_buffer("0x3535353535353535353535353535353535353535"),
             "",
             "",
             <<28>>,
             "",
             ""
           ]

    assert Transaction.to_list(
             @not_signed_transaction_map |> Map.keys()
             |> Enum.reduce(%{}, fn key, acc ->
               Map.put(acc, key, to_buffer(Map.get(@not_signed_transaction_map, key)))
             end)
           ) == [
             "",
             to_buffer("0x04a817c800"),
             to_buffer("0x5208"),
             to_buffer("0x3535353535353535353535353535353535353535"),
             "",
             "",
             <<28>>,
             "",
             ""
           ]
  end

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
end
