defmodule ETH.Transaction.Setter.Test do
  use ExUnit.Case
  import ETH.Utils

  alias ETH.Transaction

  # make these raw data
  # [nonce, gas_price, gas_limit, to, value, data, v, r, s]
  # @not_signed_transaction_list [
  #   "",
  #   "0x04a817c800",
  #   "0x5208",
  #   "0x3535353535353535353535353535353535353535",
  #   "",
  #   ""
  # ]
  # @signed_transaction_list [
  #   "",
  #   "0x04a817c800",
  #   "0x5208",
  #   "0x3535353535353535353535353535353535353535",
  #   "",
  #   "",
  #   "0x25",
  #   "0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d",
  #   "0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"
  # ]
  # @not_signed_transaction_map %{
  #   nonce: 8,
  #   gas_price: 10,
  #   gas_limit: 11,
  #   to: "0x3535353535353535353535353535353535353535",
  #   value: 20,
  #   data: ""
  # }
  # @signed_transaction_map %{
  #   nonce: "0x08",
  #   gas_price: "0x04a817c800",
  #   gas_limit: "0x5208",
  #   to: "0x3535353535353535353535353535353535353535",
  #   value: "0x08",
  #   data: "",
  #   v: "0x25",
  #   r: "0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d",
  #   s: "0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d"
  # }
  #
  # test "Transaction.set(params) works when params is a list" do
  #   assert Transaction.set(@not_signed_transaction_list) == %{
  #           nonce: "",
  #           gas_price: to_buffer("0x04a817c800"),
  #           gas_limit: to_buffer("0x5208"),
  #           to: to_buffer("0x3535353535353535353535353535353535353535"),
  #           value: "",
  #           data: ""
  #         }
  # end

  # test "Transaction.set(params) works with default values when params is a list" do
  #
  # end
  #
  # test "Transaction.set(params) works when params is a map" do
  #
  # end
  #
  # test "Transaction.set(params) works with default values when params is a map" do
  #
  # end
  #
  # test "Transaction.set(sender_wallet, receiver_wallet, value) works" do
  #
  # end
  #
  # test "Transaction.set(sender_wallet, receiver_wallet, value) assigns default values when necessary" do
  #
  # end
  #
  # test "Transaction.set(sender_wallet, receiver_wallet, params) works when params is a list" do
  #
  # end
  #
  # test "Transaction.set(sender_wallet, receiver_wallet, params) works when params is a list and assigns default values" do
  #
  # end
  #
  # test "Transaction.set(sender_wallet, receiver_wallet, params) works when params is a map" do
  #
  # end
  #
  # test "Transaction.set(sender_wallet, receiver_wallet, params) works when params is a map and assigns default values" do
  #
  # end
end
