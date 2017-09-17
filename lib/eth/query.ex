# TODO: use Macro.underscore
defmodule ETH.Query do
  import ETH.Utils

  def block_number do
    Ethereumex.HttpClient.eth_block_number
    |> get_number_result
  end

  def syncing do
    Ethereumex.HttpClient.eth_syncing
    |> get_result
  end

  def get_accounts do
    Ethereumex.HttpClient.eth_accounts
    |> get_result
  end

  def gas_price do
    Ethereumex.HttpClient.eth_gas_price()
    |> get_number_result
  end

  def call(call_params) do
    Ethereumex.HttpClient.eth_call([call_params])
    |> get_result
  end

  def get_block(block_number) when is_number(block_number) do
    Ethereumex.HttpClient.eth_get_block_by_number(["0x" <> Hexate.encode(block_number), true])
    |> get_result # TODO: make camelCased to snake_cased
    |> convert_block_details
  end
  def get_block(block_hash) do
    Ethereumex.HttpClient.eth_get_block_by_hash([block_hash, true])
    |> get_result
    |> convert_block_details
  end

  def get_block_transactions(identifier) do
    get_block(identifier)
    |> Map.get("transactions")
  end

  def get_block_transaction_count(block_number) when is_number(block_number) do
    Ethereumex.HttpClient.eth_get_block_transaction_count_by_number([block_number])
    |> get_result
  end
  def get_block_transaction_count(block_hash) do
    Ethereumex.HttpClient.eth_get_block_transaction_count_by_hash([block_hash])
    |> get_result
  end

  def get_transaction_from_block(block_number, index) when is_number(block_number) do
    Ethereumex.HttpClient.eth_get_transaction_by_block_number_and_index([block_number, index])
    |> get_result
  end
  def get_transaction_from_block(block_hash, index) do
    Ethereumex.HttpClient.eth_get_transaction_by_block_hash_and_index([block_number, index])
    |> get_result
  end

  def get_balance(param, denomination \\ :ether)
  def get_balance(wallet, denomination) when is_map(wallet) do
    Ethereumex.HttpClient.eth_get_balance([wallet.eth_address])
    |> get_number_result
    |> convert(denomination)
  end
  def get_balance(eth_address, denomination) do
    Ethereumex.HttpClient.eth_get_balance([eth_address])
    |> get_number_result
    |> convert(denomination)
  end

  def get_transaction(transaction_hash) do
    Ethereumex.HttpClient.eth_get_transaction_by_hash([transaction_hash])
    |> get_result
    |> convert_transaction_details
  end

  def get_transaction_receipt(transaction_hash) do
    Ethereumex.HttpClient.eth_get_transaction_receipt([transaction_hash])
    |> get_result
    |> Enum.reduce(%{}, fn(tuple, acc) ->
      {key, value} = tuple

      case key do
        "transactionHash" -> Map.put(acc, :transaction_hash, value)
        "transactionIndex" -> Map.put(acc, :transaction_index, convert_to_number(value))
        "blockHash" -> Map.put(acc, :block_hash, value)
        "blockNumber" -> Map.put(acc, :block_number, convert_to_number(value))
        "cumulativeGasUsed" -> Map.put(acc, :cumulative_gas_used, convert_to_number(value))
        "gasUsed" -> Map.put(acc, :gas_used, convert_to_number(value))
        "contractAddress" -> Map.put(acc, :contract_address, value)
        "logs" ->
          Map.put(acc, :logs, Enum.map(value, fn(log) ->
            convert_transaction_log(log)
          end))
        "logsBloom" -> Map.put(acc, :logs_bloom, value)
        _ -> Map.put(acc, String.to_atom(key), value)
      end
    end)
  end

  def get_transaction_count(wallet) when is_map(wallet) do
    Ethereumex.HttpClient.eth_get_transaction_count([wallet.eth_address])
    |> get_number_result
  end
  def get_transaction_count(eth_address) do
    Ethereumex.HttpClient.eth_get_transaction_count([eth_address])
    |> get_number_result
  end

  def estimate_gas(transaction \\ %{data: ""})
  def estimate_gas(transaction = %{to: _to, data: _data}) do
    Ethereumex.HttpClient.eth_estimate_gas([transaction])
    |> get_number_result
  end

  defp get_result({:ok, eth_result}), do: Map.get(eth_result, "result")
  defp get_result(error), do: raise error

  defp get_number_result(eth_result) do
    get_result(eth_result) |> convert_to_number
  end

  defp convert_to_number(result) do
    result
    |> String.slice(2..-1)
    |> Hexate.to_integer
  end

  defp convert_transaction_log(log) do
    Enum.reduce(log, %{}, fn(tuple, acc) ->

      {key, value} = tuple

      case key do
        "blockHash" -> Map.put(acc, :block_hash, value)
        "blockNumber" -> Map.put(acc, :block_number, convert_to_number(value))
        "logIndex" -> Map.put(acc, :log_index, convert_to_number(value))
        "transactionHash" -> Map.put(acc, :transaction_hash, value)
        "transactionIndex" -> Map.put(acc, :transaction_index, convert_to_number(value))
        "transactionLogIndex" -> Map.put(acc, :transaction_log_index, convert_to_number(value))
        _ -> Map.put(acc, String.to_atom(key), value)
      end
    end)
  end
  defp convert_transaction_details(transaction) do
    Enum.reduce(transaction, %{}, fn(tuple, acc) ->
      {key, value} = tuple

      case key do
        "nonce" -> Map.put(acc, :nonce, convert_to_number(value))
        "blockHash" -> Map.put(acc, :block_hash, value)
        "blockNumber" -> Map.put(acc, :block_number, convert_to_number(value))
        "transactionIndex" -> Map.put(acc, :transaction_index, convert_to_number(value))
        "value" -> Map.put(acc, :value, convert_to_number(value))
        "gasPrice" -> Map.put(acc, :gas_price, convert_to_number(value))
        "gas" -> Map.put(acc, :gas, convert_to_number(value))
        "networkId" -> Map.put(acc, :network_id, value)
        "publicKey" -> Map.put(acc, :public_key, value)
        "standardV" -> Map.put(acc, :standard_v, value)
        _ -> Map.put(acc, String.to_atom(key), value)
      end
    end)
  end

  defp convert_block_details(result) do
    result
    |> Enum.reduce(%{}, fn(tuple, acc) ->
      {key, value} = tuple

      case key do
        "number" -> Map.put(acc, :number, convert_to_number(value))
        "parentHash" -> Map.put(acc, :parent_hash, value)
        "mixHash" -> Map.put(acc, :mix_hash, value)
        "sha3Uncles" -> Map.put(acc, :sha3_uncles, value)
        "logsBloom" -> Map.put(acc, :logs_bloom, value)
        "transactionsRoot" -> Map.put(acc, :transactions_root, value)
        "stateRoot" -> Map.put(acc, :state_root, value)
        "receiptsRoot" -> Map.put(acc, :receipt_root, value)
        "extraData" -> Map.put(acc, :extra_data, value)
        "size" -> Map.put(acc, :size, convert_to_number(value))
        "sealFields" -> Map.put(acc, :seal_fields, value)
        "gasLimit" -> Map.put(acc, :gas_limit, convert_to_number(value))
        "gasUsed" -> Map.put(acc, :gas_used, convert_to_number(value))
        "timestamp" -> Map.put(acc, :timestamp, convert_to_number(value))
        "difficulty" -> Map.put(acc, :difficulty, convert_to_number(value))
        "totalDifficulty" -> Map.put(acc, :total_difficulty, convert_to_number(value))
        "transactions" ->
            Map.put(acc, String.to_atom(key), Enum.map(value, fn(transaction) ->
              convert_transaction_details(transaction)
            end))
        _ -> Map.put(acc, String.to_atom(key), value)
      end
    end)
  end
end
