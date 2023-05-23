defmodule ETH.TestClient do
  @block_time 350

  def start do
    spawn(fn ->
      "node_modules/.bin/ganache -b=0.35 -m=\" parent leopard beauty edit tilt what blast next huge need print advice evolve move explain govern grab raccoon gown gravity gloom walnut silver reopen\""
      |> String.to_charlist()
      |> :os.cmd()

      # this makes the process hang, maybe with elixir ports we can intercept?
    end)

    wait_until_the_port_is_open() # NOTE: since couldnt find a way to intercept the testrpc init no way to know when test blockchain actually starts
    advance_block_by(1)
  end

  def stop do
    "pkill -f node_modules/.bin/ganache"
    |> String.to_charlist()
    |> :os.cmd()
  end

  def advance_block_by(block_count) do
    block_no_during_function_call = ETH.block_number!()

    wait_until_next_block(block_no_during_function_call)

    if block_count > 1 do
      Process.sleep(block_count * @block_time - @block_time)
    end
  end

  def wait_until_next_block(initial_block_number) do
    Process.sleep(div(@block_time, 10))

    if ETH.block_number!() == initial_block_number do
      wait_until_next_block(initial_block_number)
    end
  end

  def wait_until_the_port_is_open do
    case ETH.block_number() do
      {:ok, res} -> res
      {:error, _} -> wait_until_the_port_is_open()
    end
  end
end
