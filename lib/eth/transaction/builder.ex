defmodule ETH.Transaction.Builder do
  import ETH.Transaction.Parser

  @moduledoc """
    This module converts transaction parameters as a list or map to
    Ethereum Transaction map. The result map is encoded with default ethereum hex encodings for
    every value so you can sign and send it to any Ethereum client. It also assigns default values
    and calculates gas prices if not provided.
  """

  def build(params) when is_list(params) do
    params
    |> build_params_from_list
    |> parse
  end

  def build(params) when is_map(params) do
    params
    |> build_params_from_map
    |> parse
  end

  def build(wallet, params) do
    result =
      cond do
        is_map(params) ->
          target_params = params |> Map.merge(%{from: wallet.eth_address})
          build_params_from_map(target_params)

        is_list(params) ->
          target_params = params |> Keyword.merge(from: wallet.eth_address)
          build_params_from_list(target_params)
      end

    parse(result)
  end

  def build(sender_wallet, receiver_wallet, value) when is_number(value) do
    %{from: sender_wallet.eth_address, to: receiver_wallet.eth_address, value: value}
    |> build_params_from_map
    |> parse
  end

  def build(sender_wallet, receiver_wallet, params) do
    result =
      cond do
        is_map(params) ->
          target_params =
            params
            |> Map.merge(%{from: sender_wallet.eth_address, to: receiver_wallet.eth_address})

          build_params_from_map(target_params)

        is_list(params) ->
          target_params =
            params
            |> Keyword.merge(from: sender_wallet.eth_address, to: receiver_wallet.eth_address)

          build_params_from_list(target_params)
      end

    parse(result)
  end

  defp build_params_from_list(params) do
    to = Keyword.get(params, :to, "")
    value = Keyword.get(params, :value, 0)
    gas_price = Keyword.get_lazy(params, :gas_price, fn -> ETH.gas_price!() end)
    data = Keyword.get(params, :data, "")

    target_data =
      if data !== "" && !String.starts_with?(data, "0x"),
        do: "0x" <> Hexate.encode(data),
        else: data

    nonce = Keyword.get_lazy(params, :nonce, fn -> generate_nonce(Keyword.get(params, :from)) end)
    chain_id = Keyword.get(params, :chain_id, 3)

    gas_limit =
      Keyword.get_lazy(
        params,
        :gas_limit,
        fn ->
          ETH.estimate_gas!(%{
            to: to,
            value: value,
            data: target_data,
            nonce: nonce,
            chain_id: chain_id
          })
        end
      )

    %{
      chain_id: chain_id,
      nonce: nonce,
      gas_price: gas_price,
      gas_limit: gas_limit,
      to: to,
      value: value,
      data: target_data
    }
  end

  defp build_params_from_map(params) do
    to = Map.get(params, :to, "")
    value = Map.get(params, :value, 0)
    gas_price = Map.get_lazy(params, :gas_price, fn -> ETH.gas_price!() end)
    data = Map.get(params, :data, "")

    target_data =
      if data !== "" && !String.starts_with?(data, "0x"),
        do: "0x" <> Hexate.encode(data),
        else: data

    nonce = Map.get_lazy(params, :nonce, fn -> generate_nonce(Map.get(params, :from)) end)
    chain_id = Map.get(params, :chain_id, 3)

    gas_limit =
      Map.get_lazy(
        params,
        :gas_limit,
        fn ->
          ETH.estimate_gas!(%{
            to: to,
            value: value,
            data: target_data,
            nonce: nonce,
            chain_id: chain_id
          })
        end
      )

    %{
      chain_id: chain_id,
      nonce: nonce,
      gas_price: gas_price,
      gas_limit: gas_limit,
      to: to,
      value: value,
      data: target_data
    }
  end

  defp generate_nonce(nil), do: 0
  defp generate_nonce(address), do: ETH.get_transaction_count!(address, "pending")
end
