use alloy::primitives::{Address, B256, U256, b256};
use alloy::providers::Provider;
use serde::Serialize;
use thiserror::Error;

pub type BindingsResult<T> = Result<T, BindingsError>;

#[derive(Error, Debug, Serialize)]
pub enum BindingsError {
    #[error("The RPC transport returned an error.")]
    RpcTransportError(String),
    #[error("The chain ID {0} is not in the list of named chains.")]
    ChainIdUnknown(u64),
    #[error(
        "The current protocol adapter version has not been deployed on the provided chain '{0}'."
    )]
    UnsupportedChain(String),
}

/// The [ERC-1967](https://eips.ethereum.org/EIPS/eip-1967) implementation slot.
pub const ERC1967_IMPLEMENTATION_SLOT: B256 =
    b256!("360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc");

/// Reads the current implementation address an ERC-1967 proxy delegates to from its implementation slot.
pub async fn erc1967_implementation<P: Provider>(
    provider: &P,
    proxy: Address,
) -> BindingsResult<Address> {
    let value = provider
        .get_storage_at(proxy, U256::from_be_bytes(ERC1967_IMPLEMENTATION_SLOT.0))
        .await
        .map_err(|err| BindingsError::RpcTransportError(err.to_string()))?;

    Ok(Address::from_word(B256::from(value)))
}
