# Beta Finance Invitational audit details
- Total Prize Pool: $24,150 USDC
  - HM awards: $16,000 USDC
  - QA awards: $1,500 USD
  - Gas awards: $1,100 USDC
  - Judge awards: $5,050 USDC
  - Scout awards: $500 USDC
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2023-11-beta-finance-invitational/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts November 1, 2023 20:00 UTC
- Ends November 6, 2023 20:00 UTC

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://gist.github.com/JustDravee/c830761b3625c972499e279782dcb508).

_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

### Known Issues
- **Trust Issue of Admin Keys:** In the Omni protocol, there are a series of privileged accounts that play a critical role in governing and regulating the protocol-wide operations (e.g., configure various system parameters and execute privileged operations). Admin keys will be held by a Safe multisig.
- **MEV Issues for Liquidations and Socialize Loss:** If bad debt arises after liquidation, the protocol will pause to prevent the user from
withdrawing, and then call OmniToken.socializeLoss() to cover the bad debt using the user's
deposits.
However, the user can front-run the liquidation transaction that pauses the protocol to
withdraw assets before the protocol is paused, thus preventing losses from being caused by
OmniToken.socializeLoss() later.
- **Adversary Whale Bad Actor:** If a user borrows and repays in the same block, the user doesn't have to pay any interest since
interest only grows over time. For OmniToken, the max borrowing is all deposits.
So, a whale can borrow all the deposits of a certain OmniToken in the first transaction of the
block and repay it in the last transaction of the block, then all the borrowing/withdrawing
transactions in between will fail due to insufficient assets. We recognize these griefing attacks could potentially take place.
- **Borrow Factor Updated to 0 from non-0:** If borrow factor is set to 0 from non-0 then the any attempts at liquidation will always revert. We recognize the admin should exercise caution when making any changes to configurations and those changes should undergo strong testing.
- **Incompatible with rebase tokens:** The protocol does not support rebase tokens.
- **Unknown implementation of custom oracle:** The protocol accepts the use of a custom oracle as well that can be whitelisted. The implementation of this oracle is unknown, so it is out of scope.

# Overview

There are eight files that are in the scope for the audit:
- `OmniPool.sol`: The main contract of the protocol, responsible for managing configurations and risk management for the protocol.
- `OmniToken.sol`: Contract responsible for handling pooling assets that may be used as collateral and are borrowable for the protocol.
- `OmniTokenNoBorrow.sol`: Contract responsible for handling deposits of tokens that are not borrowable, i.e. will only be used as collateral for the protocol.
- `IRM.sol`: The interest rate model for the protocol. Interest rates for the protocol depend on both utilization and the tranche of the borrow.
- `OmniOracle.sol`: The oracle contract for the protocol. Responsible for returning prices in the base unit of the token.
- `WETHGateway.sol`: A contract to assist with depositing of native ETH into the protocol only. This contract does not support withdrawing ETH natively.
- `WithUnderlying.sol`: An abstract contract that is responsible for handling transfers of the underlying token and storing address data.
- `SubAccount.sol`: A library for retrieving the subaccount for any user address given a uint96 subId. Provides helper methods to convert between the subaccount and the original argument inputs.

All contracts follow the `TransparentUpgradeableProxy` pattern with `ProxyAdmin`, for more information see [here](https://docs.openzeppelin.com/contracts/4.x/api/proxy#TransparentUpgradeableProxy).

It is highly encouraged that auditors read the [Omni Protocol Whitepaper](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Whitepaper.pdf) within the repository. 

The protocol introduces a novel concept of "risk tranches" for asset pools that allows lenders to opt-in and opt-out of lending to certain collateral assets, so lenders earn the maximum yield for their risk profile and borrowers have access to maximum liquidity. In addition, the protocol introduces collision-free sub-accounts for asset management, high efficiency borrowing modes, a joint risk and utilization interest model, timed collateral, proportional loss socialization, and dynamic liquidations using dutch auctions.

![CLOC](https://github.com/code-423n4/2023-11-betafinance/blob/main/cloc.png)

## Links

- **Website:** [Website](https://betafinance.org)
- **Twitter:** [@beta_finance](https://twitter.com/beta_finance)
- **Discord:** [Beta Discord](https://discord.gg/WSSf4Am69Z)


# Scope


| Contract | SLOC | Purpose |
| ----------- | ----------- | ----------- |
| [OmniPool.sol](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Protocol/src/OmniPool.sol) | 417 | The main contract of the protocol, responsible for managing configurations and risk management for the protocol. This is the main entrypoint for liquidation, borrows, and repays. | 
| [OmniToken.sol](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Protocol/src/OmniToken.sol) | 332 | Contract responsible for handling pooling assets that may be used as collateral and are borrowable for the protocol. Main entry point for deposit and withdraw.| 
| [OmniTokenNoBorrow.sol](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Protocol/src/OmniTokenNoBorrow.sol) | 73 |Contract responsible for handling deposits of tokens that are not borrowable, i.e. will only be used as collateral for the protocol. Main entry point for deposit and withdraw. |
| [IRM.sol](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Protocol/src/IRM.sol) | 57 | The interest rate model for the protocol. Interest rates for the protocol depend on both utilization and the tranche of the borrow. |
| [OmniOracle.sol](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Protocol/src/OmniOracle.sol) | 54 | The oracle contract for the protocol. Responsible for returning prices in the base unit of the token. |
| [WETHGateway.sol](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Protocol/src/WETHGateway.sol) | 29 | A contract to assist with depositing of native ETH into the protocol only. This contract does not support withdrawing ETH natively. |
| [WithUnderlying.sol](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Protocol/src/WithUnderlying.sol) | 24 | An abstract contract that is responsible for handling transfers of the underlying token and storing address data. |
| [SubAccount.sol](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Protocol/src/SubAccount.sol) | 13 | A library for retrieving the subaccount for any user address given a uint96 subId. Provides helper methods to convert between the subaccount and the original argument inputs. |

## Out of scope
- External libraries: `openzeppelin-contracts@v4.8.0/*`, `openzeppelin-contracts-upgradeable@v4.8.0/*`


# Additional Context
Read the [whitepaper](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Whitepaper.pdf).

## Attack ideas (Where to look for bugs)
- Changing the `borrowTier` of a subaccount
- Duplicating markets being tracked to double count collateral
- Manipulation of price oracle, when the oracle is not a custom oracle
- Manipulating balance values due to rounding errors
- Protocol will list a separate OmniToken (for borrowing, no collateral) and OmniTokenNoBorrow (for collateral, no borrowing) for high risk assets, e.g. BETA. Check to make sure this scenario cannot be taken advantage of
- OmniOracle contract Chainlink/Band method calls
- `accrue()` method in `OmniToken.sol`
- OmniPool liquidations when account unhealthy and if collateral is expired
- evaluateAccount tracks proper amounts and applies factors correctly
- socializeLoss correctly deducts the intended amount and doesn't cause rounding issues resulting in loss of funds

## Main invariants
See [whitepaper](https://github.com/code-423n4/2023-11-betafinance/blob/main/Omni_Whitepaper.pdf) for more information.

1. The deposits (d) available to higher risk tranches (t) are always available to lower risk tranches.
2. Interest (i) earned from lower risk tranches (t) is split
with all higher risk tranches proportionately.
3. The cumulative total borrow of the asset must be less than or equal to the cumulative total deposit when summed from the highest to lowest tranches. 

## Scoping Details 
- If you have a public code repo, please share it here: https://github.com/beta-finance/Omni_C4 
- How many contracts are in scope?: 8   
- Total SLoC for these contracts?: 999  
- How many external imports are there?: 8  
- How many separate interfaces and struct definitions are there for the contracts within scope?: 10 interfaces 9 structs  
- Does most of your code generally use composition or inheritance?: Composition   
- How many external calls?: 2
- What is the overall line coverage percentage provided by your tests?: 95
- Is this an upgrade of an existing system?: False
- Check all that apply (e.g. timelock, NFT, AMM, ERC20, rollups, etc.): Side-Chain, ERC-20 Token, Non ERC-20 Token  
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?: False   
- Please describe required context:   
- Does it use an oracle?: Band, Chainlink  
- Describe any novel or unique curve logic or mathematical models your code uses: We use standard kink-based models for determining interest rates and liquidation bonuses. Some unique logic is that we separate deposits into tranches, where higher risk tier tranches earn yield from lower tranches, and also deposits are available to all borrowers less risky than the deposited tranche. See invariants.
- Is this either a fork of or an alternate implementation of another project?: No
- Does it use a side-chain?: Yes, BNBChain
- Describe any specific areas you would like addressed: OmniOracle contract, `accrue()` method in `OmniToken.sol`, OmniPool liquidations, evaluateAccount, and socializeLoss.

# Tests
Setup:

```bash
git submodule update --init --recursive
curl -L https://foundry.paradigm.xyz | bash
foundryup
```
Test:
```bash
forge test
```
Coverage:
```bash
forge coverage --report summary
```

If forge fails to run, please confirm you are running the latest version. This was tested with forge 0.2.0.

Note: After running forge you need to run yarn build again for the Hardhat tests to work.
*Provide every step required to build the project from a fresh git clone, as well as steps to run the tests with a gas report.* 

*Note: Many wardens run Slither as a first pass for testing.  Please document any known errors with no workaround.* 
