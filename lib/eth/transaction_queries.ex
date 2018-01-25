defmodule ETH.TransactionQueries do
  import ETH.Query

  alias Ethereumex.HttpClient

  def get_block_transactions(identifier) do
    case get_block(identifier) do
      {:ok, block} ->
        {:ok,
         (block.transactions || [])
         |> Enum.map(fn transaction ->
           convert_transaction_details(transaction)
         end)}

      error ->
        error
    end
  end

  def get_block_transactions!(identifier) do
    get_block!(identifier) |> Map.get(:transactions, [])
    |> Enum.map(fn transaction ->
      convert_transaction_details(transaction)
    end)
  end

  def get_block_transaction_count(block_number) when is_number(block_number) do
    case HttpClient.eth_get_block_transaction_count_by_number(block_number) do
      {:ok, transaction_count} -> {:ok, transaction_count}
      error -> error
    end
  end

  def get_block_transaction_count(block_hash) do
    case HttpClient.eth_get_block_transaction_count_by_hash(block_hash) do
      {:ok, transaction_count} -> {:ok, transaction_count}
      error -> error
    end
  end

  def get_block_transaction_count!(block_number) when is_number(block_number) do
    {:ok, transaction_count} = HttpClient.eth_get_block_transaction_count_by_number(block_number)

    transaction_count
  end

  def get_block_transaction_count!(block_hash) do
    {:ok, transaction_count} = HttpClient.eth_get_block_transaction_count_by_hash(block_hash)

    transaction_count
  end

  def get_transaction_from_block(block_number, index) when is_number(block_number) do
    case HttpClient.eth_get_transaction_by_block_number_and_index(block_number, index) do
      {:ok, transaction} -> {:ok, transaction}
      error -> error
    end
  end

  def get_transaction_from_block(block_hash, index) do
    case HttpClient.eth_get_transaction_by_block_hash_and_index(block_hash, index) do
      {:ok, transaction} -> {:ok, transaction}
      error -> error
    end
  end

  def get_transaction_from_block!(block_number, index) when is_number(block_number) do
    {:ok, transaction} =
      HttpClient.eth_get_transaction_by_block_number_and_index(block_number, index)

    transaction
  end

  def get_transaction_from_block!(block_hash, index) do
    {:ok, transaction} = HttpClient.eth_get_transaction_by_block_hash_and_index(block_hash, index)

    transaction
  end

  def get_transaction(transaction_hash) do
    case HttpClient.eth_get_transaction_by_hash(transaction_hash) do
      {:ok, raw_transaction} -> {:ok, convert_transaction_details(raw_transaction)}
      error -> error
    end
  end

  def get_transaction!(transaction_hash) do
    {:ok, raw_transaction} = HttpClient.eth_get_transaction_by_hash(transaction_hash)

    convert_transaction_details(raw_transaction)
  end

  def get_transaction_receipt(transaction_hash) do
    case HttpClient.eth_get_transaction_receipt(transaction_hash) do
      {:ok, raw_transaction_receipt} ->
        {:ok, convert_transaction_receipt(raw_transaction_receipt)}

      error ->
        error
    end
  end

  def get_transaction_receipt!(transaction_hash) do
    {:ok, raw_transaction_receipt} = HttpClient.eth_get_transaction_receipt(transaction_hash)
    convert_transaction_receipt(raw_transaction_receipt)
  end

  def get_transaction_count(wallet) when is_map(wallet) do
    case HttpClient.eth_get_transaction_count(wallet.eth_address) do
      {:ok, hex_transaction_count} -> {:ok, convert_to_number(hex_transaction_count)}
      error -> error
    end
  end

  def get_transaction_count(eth_address) do
    case HttpClient.eth_get_transaction_count(eth_address) do
      {:ok, hex_transaction_count} -> {:ok, convert_to_number(hex_transaction_count)}
      error -> error
    end
  end

  def get_transaction_count!(wallet) when is_map(wallet) do
    {:ok, hex_transaction_count} = HttpClient.eth_get_transaction_count(wallet.eth_address)

    convert_to_number(hex_transaction_count)
  end

  def get_transaction_count!(eth_address) do
    {:ok, hex_transaction_count} = HttpClient.eth_get_transaction_count(eth_address)

    convert_to_number(hex_transaction_count)
  end

  defp convert_to_number(result) do
    result
    |> String.slice(2..-1)
    |> Hexate.to_integer()
  end

  def convert_transaction_receipt(result) do
    result
    |> Enum.reduce(%{}, fn tuple, acc ->
      {key, value} = tuple

      case key do
        "transactionIndex" ->
          Map.put(acc, :transaction_index, convert_to_number(value))

        "blockNumber" ->
          Map.put(acc, :block_number, convert_to_number(value))

        "cumulativeGasUsed" ->
          Map.put(acc, :cumulative_gas_used, convert_to_number(value))

        "gasUsed" ->
          Map.put(acc, :gas_used, convert_to_number(value))

        "logs" ->
          Map.put(
            acc,
            :logs,
            Enum.map(value, fn log ->
              convert_transaction_log(log)
            end)
          )

        _ ->
          Map.put(acc, key |> Macro.underscore() |> String.to_atom(), value)
      end
    end)
  end
end
