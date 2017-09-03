defmodule ETH.TransactionsTest do
  use ExUnit.Case

  @transactions File.read!("test/fixtures/transactions.json") |> Poison.decode!
  @eip155_transactions File.read!("test/fixtures/eip155_vitalik_tests.json") |> Poison.decode!

  # test "verify signature" do
  #   @transactions |> Enum.each(fn(transaction) ->
  #     hash = # ETH.Transaction.hash()
  #     # transaction
  #
  #     # ETH.Transaction.verify_signature([v: v, r: r, s: s])
  #
  #     # signed_transaction
  #     # assert ExRLP.encode(transaction.raw) == signed_transaction
  #
  #     # NOTE: t
  #   end)
  #
  # end

  test "can get transactions sender address after signing it" do
    @transactions |> Enum.each(fn(transaction) ->
      transaction_params = ETH.Transaction.decode_transaction_list(transaction.raw)
      signature = ETH.Transaction.sign_transaction(transaction_params, transaction.privateKey)
      assert ETH.Transaction.get_sender_address(signature) == transaction.sendersAddress
    end)
  end

  # test "can get transactions sender public kye after signing it" do
  #
  # end

  # NOTE: maybe verify/check_gas function and tests
  # NOTE: maybe roundtrip a transaction encoding/decoding
  # there are upfront gas/costs tests that we probably dont need

  # test "verify EIP155 Signature based on Vitalik\'s tests" do
  #
  # end
end

# TODO: also implement transaction-runner tests
