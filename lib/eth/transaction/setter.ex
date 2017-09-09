defmodule ETH.Transaction.Setter do
  import ETH.Transaction.Parser

  def set(params) when is_list(params) do
    params
    |> set_params_from_list
    |> parse
  end
  def set(params) when is_map(params) do
    params
    |> set_params_from_map
    |> parse
  end
  def set(wallet, params) do
    result = cond do
      is_map(params) ->
        target_params = params |> Map.merge(%{from: wallet.eth_address})
        set_params_from_map(target_params)
      is_list(params) ->
        target_params = params |> Keyword.merge([from: wallet.eth_address])
        set_params_from_list(target_params)
    end

    parse(result)
  end
  def set(sender_wallet, receiver_wallet, value) when is_number(value) do
    %{from: sender_wallet.eth_address, to: receiver_wallet.eth_address, value: value}
    |> set_params_from_map
    |> parse
  end
  def set(sender_wallet, receiver_wallet, params) do
    result = cond do
      is_map(params) ->
        target_params = params
          |> Map.merge(%{from: sender_wallet.eth_address, to: receiver_wallet.eth_address})
        set_params_from_map(target_params)
      is_list(params) ->
        target_params = params
          |> Keyword.merge([from: sender_wallet.eth_address, to: receiver_wallet.eth_address])
        set_params_from_list(target_params)
    end

    parse(result)
  end

  defp set_params_from_list(params) do
    to = Keyword.get(params, :to, "")
    value = Keyword.get(params, :value, 0)
    gas_price = Keyword.get(params, :gas_price, ETH.Query.gas_price())
    data = Keyword.get(params, :data, "")
    nonce = Keyword.get(params, :nonce, ETH.Query.get_transaction_count(params[:from]))
    chain_id = Keyword.get(params, :chain_id, 3)
    gas_limit = Keyword.get(params, :gas_limit, ETH.Query.estimate_gas(%{
      to: to, value: value, data: data, nonce: nonce, chain_id: chain_id
    }))

    %{nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data}
  end

  defp set_params_from_map(params) do
    to = Map.get(params, :to, "")
    value = Map.get(params, :value, 0)
    gas_price = Map.get(params, :gas_price, ETH.Query.gas_price())
    data = Map.get(params, :data, "")
    nonce = Map.get(params, :nonce, ETH.Query.get_transaction_count(params.from))
    chain_id = Map.get(params, :chain_id, 3)
    gas_limit = Map.get(params, :gas_limit, ETH.Query.estimate_gas(%{
      to: to, value: value, data: data, nonce: nonce, chain_id: chain_id
    }))

    %{nonce: nonce, gas_price: gas_price, gas_limit: gas_limit, to: to, value: value, data: data}
  end
end
