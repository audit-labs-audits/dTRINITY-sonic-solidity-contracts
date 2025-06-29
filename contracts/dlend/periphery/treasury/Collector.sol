// SPDX-License-Identifier: AGPL-3.0
/* ———————————————————————————————————————————————————————————————————————————————— *
 *    _____     ______   ______     __     __   __     __     ______   __  __       *
 *   /\  __-.  /\__  _\ /\  == \   /\ \   /\ "-.\ \   /\ \   /\__  _\ /\ \_\ \      *
 *   \ \ \/\ \ \/_/\ \/ \ \  __<   \ \ \  \ \ \-.  \  \ \ \  \/_/\ \/ \ \____ \     *
 *    \ \____-    \ \_\  \ \_\ \_\  \ \_\  \ \_\\"\_\  \ \_\    \ \_\  \/\_____\    *
 *     \/____/     \/_/   \/_/ /_/   \/_/   \/_/ \/_/   \/_/     \/_/   \/_____/    *
 *                                                                                  *
 * ————————————————————————————————— dtrinity.org ————————————————————————————————— *
 *                                                                                  *
 *                                         ▲                                        *
 *                                        ▲ ▲                                       *
 *                                                                                  *
 * ———————————————————————————————————————————————————————————————————————————————— *
 * dTRINITY Protocol: https://github.com/dtrinity                                   *
 * ———————————————————————————————————————————————————————————————————————————————— */

pragma solidity ^0.8.20;

import {VersionedInitializable} from "contracts/dlend/core/protocol/libraries/aave-upgradeability/VersionedInitializable.sol";
import {IERC20} from "contracts/dlend/core/dependencies/openzeppelin/contracts/IERC20.sol";
import {ICollector} from "./interfaces/ICollector.sol";

/**
 * @title Collector
 * @notice Stores the fees collected by the protocol and allows the fund administrator
 *         to approve or transfer the collected ERC20 tokens.
 * @dev Implementation contract that must be initialized using transparent proxy pattern.
 * @author Aave
 **/
contract Collector is VersionedInitializable, ICollector {
    // Store the current funds administrator address
    address internal _fundsAdmin;

    // Revision version of this implementation contract
    uint256 public constant REVISION = 1;

    /**
     * @dev Allow only the funds administrator address to call functions marked by this modifier
     */
    modifier onlyFundsAdmin() {
        require(msg.sender == _fundsAdmin, "ONLY_BY_FUNDS_ADMIN");
        _;
    }

    /**
     * @dev Initialize the transparent proxy with the admin of the Collector
     * @param reserveController The address of the admin that controls Collector
     */
    function initialize(address reserveController) external initializer {
        _setFundsAdmin(reserveController);
    }

    /// @inheritdoc VersionedInitializable
    function getRevision() internal pure override returns (uint256) {
        return REVISION;
    }

    /// @inheritdoc ICollector
    function getFundsAdmin() external view returns (address) {
        return _fundsAdmin;
    }

    /// @inheritdoc ICollector
    function approve(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyFundsAdmin {
        token.approve(recipient, amount);
    }

    /// @inheritdoc ICollector
    function transfer(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyFundsAdmin {
        token.transfer(recipient, amount);
    }

    /// @inheritdoc ICollector
    function setFundsAdmin(address admin) external onlyFundsAdmin {
        _setFundsAdmin(admin);
    }

    /**
     * @dev Transfer the ownership of the funds administrator role.
     * @param admin The address of the new funds administrator
     */
    function _setFundsAdmin(address admin) internal {
        _fundsAdmin = admin;
        emit NewFundsAdmin(admin);
    }
}
