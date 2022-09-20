defmodule ETH.Transaction.Parser do
  import ETH.Utils

  @moduledoc """
    This module converts the input to a transaction map encoded with ethereum hex encodings.
    It can also convert the input to a transaction list if needed.
  """

  def parse("0x" <> encoded_transaction_rlp) do
    [nonce, gas_price, gas_limit, to, value, data, v, r, s] =
      encoded_transaction_rlp
      |> Base.decode16!(case: :mixed)
      |> ExRLP.decode()

    %{
      nonce: nonce,
      gas_price: gas_price,
      gas_limit: gas_limit,
      to: to,
      value: value,
      data: data,
      v: v,
      r: r,
      s: s
    }
  end

  def parse(<<transaction_rlp>>) do
    [nonce, gas_price, gas_limit, to, value, data, v, r, s] =
      transaction_rlp
      |> ExRLP.decode()

    %{
      nonce: nonce,
      gas_price: gas_price,
      gas_limit: gas_limit,
      to: to,
      value: value,
      data: data,
      v: v,
      r: r,
      s: s
    }
  end

  def parse(_transaction_list = [nonce, gas_price, gas_limit, to, value, data]) do
    %{
      nonce: to_buffer(nonce),
      gas_price: to_buffer(gas_price),
      gas_limit: to_buffer(gas_limit),
      to: to_buffer(to),
      value: to_buffer(value),
      data: to_buffer(data)
    }
  end

  def parse(_transaction_list = [nonce, gas_price, gas_limit, to, value, data, v, r, s]) do
    %{
      nonce: to_buffer(nonce),
      gas_price: to_buffer(gas_price),
      gas_limit: to_buffer(gas_limit),
      to: to_buffer(to),
      value: to_buffer(value),
      data: to_buffer(data),
      v: to_buffer(v),
      r: to_buffer(r),
      s: to_buffer(s)
    }
  end

  def parse(
        _transaction = %{
          chain_id: chain_id,
          nonce: nonce,
          gas_price: gas_price,
          gas_limit: gas_limit,
          to: to,
          value: value,
          data: data,
          v: v,
          r: r,
          s: s
        }
      ) do
    %{
      chain_id: to_buffer(chain_id),
      nonce: to_buffer(nonce),
      gas_price: to_buffer(gas_price),
      gas_limit: to_buffer(gas_limit),
      to: to_buffer(to),
      value: to_buffer(value),
      data: to_buffer(data),
      v: to_buffer(v),
      r: to_buffer(r),
      s: to_buffer(s)
    }
  end

  def parse(
        _transaction = %{
          chain_id: chain_id,
          nonce: nonce,
          gas_price: gas_price,
          gas_limit: gas_limit,
          to: to,
          value: value,
          data: data
        }
      ) do
    %{
      chain_id: to_buffer(chain_id),
      nonce: to_buffer(nonce),
      gas_price: to_buffer(gas_price),
      gas_limit: to_buffer(gas_limit),
      to: to_buffer(to),
      value: to_buffer(value),
      data: to_buffer(data)
    }
  end

  def to_list("0x" <> encoded_transaction_rlp) do
    encoded_transaction_rlp |> Base.decode16!(case: :mixed) |> ExRLP.decode()
  end

  def to_list(<<transaction_rlp>>), do: transaction_rlp |> ExRLP.decode()

  def to_list(
        _transaction = %{
          nonce: nonce,
          gas_price: gas_price,
          gas_limit: gas_limit,
          to: to,
          value: value,
          data: data,
          v: v,
          r: r,
          s: s
        }
      ) do
    [nonce, gas_price, gas_limit, to, value, data, v, r, s]
    |> Enum.map(fn value -> to_buffer(value) end)
  end

  def to_list(
        transaction = %{
          chain_id: chain_id,
          nonce: nonce,
          gas_price: gas_price,
          gas_limit: gas_limit,
          value: value,
          data: data
        }
      ) do
    to = Map.get(transaction, :to, "")
    v = Map.get(transaction, :v, <<28>>)
    r = Map.get(transaction, :r, "")
    s = Map.get(transaction, :s, "")

    [nonce, gas_price, gas_limit, to, value, data, v, r, s, chain_id]
    |> Enum.map(fn value -> to_buffer(value) end)
  end
end
