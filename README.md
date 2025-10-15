# EtherBank (Secure) + Attacker — Foundry Readme

A compact repo showing a secure ETH bank and a test attacker to demonstrate reentrancy defense. Built for **Foundry**.

## What's included

* `src/EtherBank.sol` — secure, gas-efficient deposit & withdraw (checks → effects → interactions + `ReentrancyGuard`).
* `src/Attacker.sol` — test attacker for local/testnet use only (configurable recursion).

## Quick start

1. Install Foundry:

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```
2. Install dependencies:

   ```bash
   forge install OpenZeppelin/openzeppelin-contracts
   ```
3. Compile:

   ```bash
   forge build
   ```
4. Test locally:

   ```bash
   forge test -vvv
   ```

## Notes

* **Security:** `EtherBank` uses `nonReentrant` and state-first logic to block reentrancy.
* **Gas:** optimized with local caching, `delete`, and custom errors.
* **Ethical use only:** run `Attacker.sol` only on local/testnets or contracts you own.

## Structure

```
contracts/
  ├── EtherBank.sol
  └── Attacker.sol
```

## License

MIT
---

Want this even shorter or formatted for GitHub with badges or example tests? Tell me what to add and I’ll update it.
