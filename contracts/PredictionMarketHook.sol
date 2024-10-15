// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import { 
    LiquidityManagement,
    RemoveLiquidityKind,
    TokenConfig,
    PoolSwapParams,
    AfterSwapParams,
    HookFlags
} from "./ext/balancer-v3-monorepo/interfaces/vault/VaultTypes.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { BaseHooks } from "./ext/balancer-v3-monorepo/vault/BaseHooks.sol";
import { VaultGuard } from "./ext/balancer-v3-monorepo/vault/VaultGuard.sol";
import { IHooks } from "./ext/balancer-v3-monorepo/interfaces/vault/IHooks.sol";
import { IVault } from "./ext/balancer-v3-monorepo/interfaces/vault/IVault.sol";
import { IBasePoolFactory } from "./ext/balancer-labs/v3-interfaces/vault/IBasePoolFactory.sol";


contract PredictionMarketHook is VaultGuard, BaseHooks  {
    // Only pools from a specific factory are able to register and use this hook.
    address private immutable _allowedFactory;

    /**
     * @notice A new `PredictionMarketRegistered` contract has been registered successfully for a given factory and pool.
     * @dev If the registration fails the call will revert, so there will be no event.
     * @param hooksContract This contract
     * @param pool The pool on which the hook was registered
     */
    event PredictionMarketRegistered(address indexed hooksContract, address indexed pool);

    constructor(
        IVault vault,
        address factory
    ) VaultGuard(vault) { 
        _allowedFactory = factory;
    }

    /// @inheritdoc IHooks
    function onRegister(
        address factory,
        address pool,
        TokenConfig[] memory,
        LiquidityManagement calldata
    ) public override returns (bool) {
        emit PredictionMarketRegistered(address(this), pool);

        return factory == _allowedFactory && IBasePoolFactory(factory).isPoolFromFactory(pool);
    }

    /// @inheritdoc IHooks
    function getHookFlags() public pure override returns (HookFlags memory hookFlags) {
        hookFlags.shouldCallBeforeSwap = true;
    }

    /// @inheritdoc IHooks
    function onAfterSwap(AfterSwapParams calldata params) public override returns (bool, uint256) {
        // return the amountCalculated with no modifications. 
        return (true, params.amountCalculatedRaw);
    }

}