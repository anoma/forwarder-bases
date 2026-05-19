[![Contracts Tests](https://github.com/anoma/forwarder-bases/actions/workflows/contracts.yml/badge.svg)](https://github.com/anoma/forwarder-bases/actions/workflows/contracts.yml) [![soldeer.xyz](https://img.shields.io/badge/soldeer.xyz-anoma--forwarder--bases-blue?logo=ethereum)](https://soldeer.xyz/project/anoma--forwarder--bases) [![License](https://img.shields.io/badge/license-MIT-blue)](https://raw.githubusercontent.com/anoma/forwarder-bases/refs/heads/main/contracts/LICENSE)

[![Bindings Tests](https://github.com/anoma/forwarder-bases/actions/workflows/bindings.yml/badge.svg)](https://github.com/anoma/forwarder-bases/actions/workflows/bindings.yml) [![crates.io](https://img.shields.io/badge/crates.io-anoma--forwarder--bases--bindings-blue?logo=rust)](https://crates.io/crates/anoma-forwarder-bases-bindings) [![License](https://img.shields.io/badge/license-MIT-blue)](https://raw.githubusercontent.com/anoma/forwarder-bases/refs/heads/main/bindings/LICENSE)

# Forwarder Bases

Base contracts written in Solidity to inherit from when implementing a forwarder for the [Anoma EVM protocol adapter](https://github.com/anoma/pa-evm).

## Project Structure

This monorepo is structured as follows:

```
.
├── audits
├── bindings
├── contracts
├── Cargo.lock
├── Cargo.toml
├── README.md
└── RELEASE_CHECKLIST.md
```

The [contracts](./contracts/) folder contains the contracts written in [Solidity](https://soliditylang.org/) as well as [Foundry forge](https://book.getfoundry.sh/forge/) tests.

The [bindings](./bindings/) folder provides [Rust](https://www.rust-lang.org/) bindings to interact with the contracts in rust.

## Audits

1. Informal Systems
   - Company Website: https://informal.systems
   - Contracts: [`ForwarderBase.sol`](./contracts/src/ForwarderBase.sol), [`EmergencyMigratableForwarderBase.sol`](./contracts/src/EmergencyMigratableForwarderBase.sol)
   - Repo: [anoma/anomapay-erc20-forwarder](https://github.com/anoma/anomapay-erc20-forwarder)
   - Commit ID: [03e60b64d9dc3845c55e34d1d0bef25392cb5b60](https://github.com/anoma/anomapay-erc20-forwarder/tree/03e60b64d9dc3845c55e34d1d0bef25392cb5b60)
   - Started: 2025-12-01
   - Finished: 2025-12-16
   - Last revised: 2025-12-19

   [📄 Audit Report (pdf)](./audits/2025-12-19_Informal_Systems_AnomaPay_Phase_I.pdf)

## Security

If you believe you've found a security issue, we encourage you to notify us via Email
at [security@anoma.foundation](mailto:security@anoma.foundation).

Please do not use the issue tracker for security issues. We welcome working with you to resolve the issue promptly.
