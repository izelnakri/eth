[![Hex Version](http://img.shields.io/hexpm/v/eth.svg?style=flat)](https://hex.pm/packages/eth) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/eth/ETH.html)

# ETH
The essential Elixir library for interacting with Ethereum blockchain. You can now create Ethereum wallets, query the blockchain and sign/send transactions, all from Elixir / Erlang Virtual Machine.

## Example

```elixir
  wallet = ETH.Wallet.create
  # %{eth_address: "0x31CF67A272A23C7A11128C97FC3B2F4C13AFD87F",
  #   private_key: "C8E2F24A806A422034990C7391B4CEB7133CD3680987FEBB5750555F99F0FC83",
  #   public_key: "04C4AA07F234226CA90FB3E8BB1590D5BEB703E449700FE0B2DF539A948289EA75220CC837CA68F429F3FB3D6677B2D63CF66277888B8209D0B3F3229CE339654C"}

  specific_private_key = "9756371A51D7FC25EDFC95A49DEF3806ED34DF2EBCA2065E543369E708C47374"
  another_wallet = ETH.Wallet.create(specific_private_key)
  # %{eth_address: "0x6A26B49D8046DC5B74D41E29F9A5CA7AD78EEC9B",
  #   private_key: "9756371A51D7FC25EDFC95A49DEF3806ED34DF2EBCA2065E543369E708C47374",
  #   public_key: "04D1F70F6048D1E22FBEBBF3AF462E3356747AB2BB81EC269C600BE6A53C3223472AA336DF0060719C6F3AEC45E40AE57ED39735B61B8F5EF989466D46CA1B72C0"}

  accounts_in_your_client = ETH.get_accounts
  # ["0xfdf5d02f2082753dda0817492d6efff7e76e47aa",
  #  "0xb9906b679aa8edd03fdf7fe396af4d9a77af4108",
  #  "0xae6463bf32efc106ad4300d902e572e1c43e6e9c",
  #  "0xb764c82ae23467be2cf90ab9019ee2464a3946f9",
  #  "0xfc5b5a6cd171f4123439f28fad9986c70572b35f",
  #  "0x7605c8812cfb51a7d2d16e598f521c9302d0ed7f",
  #  "0x7dab29cc88c2ecd69ec216b7d089a82bb95fe1ad",
  #  "0xba3a30f3c4fd2b4a44936b42ceea87ec3e53294a",
  #  "0xb3f4869ce14d6bbd659dc5d2f9a515b58b2765d2",
  #  "0x8c9cec7feacdbbf472ebcc4f61224d83c880896b"]

  first_account_in_your_client = List.first(accounts_in_your_client)
  first_account_private_key = "f121f608500f7e3379c813aa6df62864e35aa0b6cd11a2ff2c20ac84b5771fb2"

  ETH.get_balance("0x31CF67A272A23C7A11128C97FC3B2F4C13AFD87F") # 0 # this account holds no ether
  ETH.get_balance(first_account_in_your_client, :wei) # 1.0e20 -> in this example this address holds 100 ether / 1.0e20 wei

  ETH.get_transaction_count(first_account_in_your_client) # 0

  {:ok, tx_hash} = ETH.send_transaction(%{
    from: first_account_in_your_client, to: wallet[:eth_address], value: 22
  }, first_account_private_key)
  # {:ok, "0x13893d677251ddb9259263490504f3e611a0a7bff23b108641d2cb08b7af21dc"}

  ETH.get_transaction(tx_hash)
  # %{block_hash: "0xf9917088fc6750677cc1cfb4f7dcab453b21c7de2cb22ed7e6753df058bec5cf",
  #   block_number: 1, from: "0xfdf5d02f2082753dda0817492d6efff7e76e47aa",
  #   gas: 21000, gas_price: 20000000000,
  #   hash: "0x13893d677251ddb9259263490504f3e611a0a7bff23b108641d2cb08b7af21dc",
  #   input: "0", nonce: 0, to: "0x725316bb37d202b0eb203cd83238c31e983a7936",
  #   transaction_index: 0, value: 22}

  ETH.get_balance(first_account_in_your_client) # 99.99958 # in ether
  ETH.get_balance(wallet[:eth_address], :wei) # 22.0 # in wei
```

Warning: This library uses the Ethereum JSON-RPC under the hood, so you need an ethereum client such as parity/geth or testrpc to use of most of the API.

### Credits

- [Izel Nakri](https://github.com/izelnakri) - I reverse engineered ethereum JavaScript libraries in Elixir so you don't have to.

Additionally this library wouldnt exists without the libraries below:
- ExRLP
- Ethereumex
- keccakf1600
- libsecp256k1

### TODO:
contract creation via

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `eth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eth, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/eth](https://hexdocs.pm/eth).
