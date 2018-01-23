defmodule ETH.Query do
  import ETH.Utils
  alias Ethereumex.HttpClient

  def block_number do
    case HttpClient.eth_block_number() do
      {:ok, hex_block_number} -> {:ok, convert_to_number(hex_block_number)}
      error -> error
    end
  end

  def block_number! do
    {:ok, hex_block_number} = HttpClient.eth_block_number()

    hex_block_number |> convert_to_number
  end

  def syncing, do: HttpClient.eth_syncing()

  def syncing! do
    {:ok, result} = HttpClient.eth_syncing()

    result
  end

  def get_accounts, do: HttpClient.eth_accounts()

  def get_accounts! do
    {:ok, accounts} = HttpClient.eth_accounts()

    accounts
  end

  def gas_price do
    case HttpClient.eth_gas_price() do
      {:ok, hex_gas_price} -> {:ok, convert_to_number(hex_gas_price)}
      error -> error
    end
  end

  def gas_price! do
    {:ok, hex_gas_price} = HttpClient.eth_gas_price()

    convert_to_number(hex_gas_price)
  end

  # TODO: test this one
  def call(call_params), do: HttpClient.eth_call(call_params)

  def call!(call_params) do
    {:ok, result} = HttpClient.eth_call(call_params)

    result
  end

  def get_block do
    case HttpClient.eth_get_block_by_number(
           "0x" <> Hexate.encode(block_number!()),
           true
         ) do
      {:ok, raw_block_details} -> {:ok, convert_block_details(raw_block_details)}
      error -> error
    end
  end

  def get_block(block_number) when is_number(block_number) do
    case HttpClient.eth_get_block_by_number("0x" <> Hexate.encode(block_number), true) do
      {:ok, raw_block_details} -> {:ok, convert_block_details(raw_block_details)}
      error -> error
    end
  end

  def get_block(block_hash) do
    case HttpClient.eth_get_block_by_number(block_hash, true) do
      {:ok, raw_block_details} -> {:ok, convert_block_details(raw_block_details)}
      error -> error
    end
  end

  def get_block! do
    block_hash = "0x" <> Hexate.encode(block_number!())

    {:ok, raw_block_details} = HttpClient.eth_get_block_by_number(block_hash, true)

    convert_block_details(raw_block_details)
  end

  def get_block!(block_number) when is_number(block_number) do
    block_hash = "0x" <> Hexate.encode(block_number)

    {:ok, raw_block_details} = HttpClient.eth_get_block_by_number(block_hash, true)

    convert_block_details(raw_block_details)
  end

  def get_block!(block_hash) do
    {:ok, raw_block_details} = HttpClient.eth_get_block_by_number(block_hash, true)

    convert_block_details(raw_block_details)
  end

  def get_balance(param, denomination \\ :ether)

  def get_balance(wallet, denomination) when is_map(wallet) do
    case HttpClient.eth_get_balance(wallet.eth_address) do
      {:ok, hex_balance} ->
        balance =
          hex_balance
          |> convert_to_number
          |> convert(denomination)

        {:ok, balance}

      error ->
        error
    end
  end

  def get_balance(eth_address, denomination) do
    case HttpClient.eth_get_balance(eth_address) do
      {:ok, hex_balance} ->
        balance =
          hex_balance
          |> convert_to_number
          |> convert(denomination)

        {:ok, balance}

      error ->
        error
    end
  end

  def get_balance!(param, denomination \\ :ether)

  def get_balance!(wallet, denomination) when is_map(wallet) do
    {:ok, hex_balance} = HttpClient.eth_get_balance(wallet.eth_address)

    hex_balance
    |> convert_to_number
    |> convert(denomination)
  end

  def get_balance!(eth_address, denomination) do
    {:ok, hex_balance} = HttpClient.eth_get_balance(eth_address)

    hex_balance
    |> convert_to_number
    |> convert(denomination)
  end

  def estimate_gas(transaction \\ %{data: ""}, denomination \\ :wei)

  def estimate_gas(transaction = %{to: _to, data: _data}, denomination) do
    case HttpClient.eth_estimate_gas(transaction) do
      {:ok, hex_gas_estimate} ->
        {:ok, hex_gas_estimate |> convert_to_number |> convert(denomination) |> round}

      error ->
        error
    end
  end

  def estimate_gas!(transaction \\ %{data: ""}, denomaination \\ :wei)

  def estimate_gas!(transaction = %{to: _to, data: _data}, denomination) do
    {:ok, hex_gas_estimate} = HttpClient.eth_estimate_gas(transaction)

    hex_gas_estimate |> convert_to_number |> convert(denomination) |> round
  end

  defp get_result({:ok, eth_result}), do: Map.get(eth_result, "result")
  defp get_result(error), do: raise(error)

  def convert_transaction_log(log) do
    Enum.reduce(log, %{}, fn tuple, acc ->
      {key, value} = tuple

      case key do
        "blockNumber" -> Map.put(acc, :block_number, convert_to_number(value))
        "logIndex" -> Map.put(acc, :log_index, convert_to_number(value))
        "transactionIndex" -> Map.put(acc, :transaction_index, convert_to_number(value))
        "transactionLogIndex" -> Map.put(acc, :transaction_log_index, convert_to_number(value))
        _ -> Map.put(acc, key |> Macro.underscore() |> String.to_atom(), value)
      end
    end)
  end

  def convert_transaction_details(transaction) do
    Enum.reduce(transaction, %{}, fn tuple, acc ->
      {key, value} = tuple

      case key do
        "nonce" -> Map.put(acc, :nonce, convert_to_number(value))
        "blockNumber" -> Map.put(acc, :block_number, convert_to_number(value))
        "transactionIndex" -> Map.put(acc, :transaction_index, convert_to_number(value))
        "value" -> Map.put(acc, :value, convert_to_number(value))
        "gasPrice" -> Map.put(acc, :gas_price, convert_to_number(value))
        "gas" -> Map.put(acc, :gas, convert_to_number(value))
        _ -> Map.put(acc, key |> Macro.underscore() |> String.to_atom(), value)
      end
    end)
  end

  def convert_block_details(result) do
    result
    |> Enum.reduce(%{}, fn tuple, acc ->
      {key, value} = tuple

      case key do
        "number" ->
          Map.put(acc, :number, convert_to_number(value))

        "size" ->
          Map.put(acc, :size, convert_to_number(value))

        "gasLimit" ->
          Map.put(acc, :gas_limit, convert_to_number(value))

        "gasUsed" ->
          Map.put(acc, :gas_used, convert_to_number(value))

        "timestamp" ->
          Map.put(acc, :timestamp, convert_to_number(value))

        "difficulty" ->
          Map.put(acc, :difficulty, convert_to_number(value))

        "totalDifficulty" ->
          Map.put(acc, :total_difficulty, convert_to_number(value))

        "transactions" ->
          Map.put(
            acc,
            String.to_atom(key),
            Enum.map(value, fn transaction ->
              convert_transaction_details(transaction)
            end)
          )

        _ ->
          Map.put(acc, key |> Macro.underscore() |> String.to_atom(), value)
      end
    end)
  end

  defp convert_to_number(result) do
    result
    |> String.slice(2..-1)
    |> Hexate.to_integer()
  end
end
