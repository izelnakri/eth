Application.put_env(:ethereumex, :url, Application.get_env(:eth, :url, "http://localhost:8545"))

# "testrpc -b=1 -m=\" parent leopard beauty edit tilt what blast next huge need print advice evolve move explain govern grab raccoon gown gravity gloom walnut silver reopen\"" |> String.to_charlist |> :os.cmd()

{:ok, files} = File.ls("./test/support")

Enum.each(files, fn file ->
  Code.require_file("support/#{file}", __DIR__)
end)

ETH.TestClient.stop()

ExUnit.start()

# testrpc -b=1 -m=" parent leopard beauty edit tilt what blast next huge need print advice evolve move explain govern grab raccoon gown gravity gloom walnut silver reopen"
