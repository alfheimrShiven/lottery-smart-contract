# Provebly Random Lottery Smart Contract 💰

## About
This code is going to create a provebly random lottery smart contract!

## Functionalities 👻
1. Users can take part in the lottery by paying for the ticket
   1. The cumulative ticket fees of all participants will go to the winner of the lottery.
2. After X period of time, the lottery will automatically draw a winner
   1. And this will happen programatically.
3. The contract will be using Chainlink VRF & Automation
   1. Chainlink VRF -> Randomness
   2. Chainlink Automation -> Time based trigger for lottery draw

## Quickstart 🚀
```
git clone https://github.com/alfheimrShiven/lottery-smart-contract.git
cd lottery-smart-contract
forge build
```

## Testing
`forge test`

or

`forge test --fork-url $SEPOLIA_RPC_URL`

#### Test coverage
`forge coverage`

## Deploy
### On local ANVIL chain ⛓️
`make deploy`
### On Sepolia test net ⛓️
1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

1. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

2. Deploy

```
make deploy ARGS="--network sepolia"
```

This will setup a ChainlinkVRF Subscription for you. If you already have one, update it in the `scripts/HelperConfig.s.sol` file. It will also automatically add your contract as a consumer.

3. Register a Chainlink Automation Upkeep

[You can follow the documentation if you get lost.](https://docs.chain.link/chainlink-automation/compatible-contracts)

Go to [automation.chain.link](https://automation.chain.link/new) and register a new upkeep. Choose `Custom logic` as your trigger mechanism for automation.

4. Once **deployed** and **Upkeep registered** with Chainlink Automation, you can use EtherScan UI to interact with your lottery. 

![EtherScan UI](./img/Etherscan%20UI.png)



# Thank you! 🤗

If you appreciated this, feel free to follow me:

[![Shivens LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/shivends/)

[![Shivens Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/shiven_alfheimr)
