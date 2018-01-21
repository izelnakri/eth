Application.put_env(:ethereumex, :scheme, Application.get_env(:eth, :scheme, "http"))
Application.put_env(:ethereumex, :host, Application.get_env(:eth, :host, "localhost"))
Application.put_env(:ethereumex, :port, Application.get_env(:eth, :port, 8545))

ExUnit.start()

# testrpc -b=1 -m=" parent leopard beauty edit tilt what blast next huge need print advice evolve move explain govern grab raccoon gown gravity gloom walnut silver reopen"
