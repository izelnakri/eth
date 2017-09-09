Application.put_env(:ethereumex, :scheme, Application.get_env(:eth, :scheme, "http"))
Application.put_env(:ethereumex, :host, Application.get_env(:eth, :host, "localhost"))
Application.put_env(:ethereumex, :port, Application.get_env(:eth, :port, 8545))

ExUnit.start()
