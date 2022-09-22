// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed who, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract EVAToken is ERC20Interface, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        symbol = "EVA";
        name = "Enouva";
        decimals = 2;
        _totalSupply = 1000000;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[to] = balances[to] + amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        balances[from] = balances[from] - amount;
        allowed[from][msg.sender] = allowed[from][msg.sender] - amount;
        balances[to] = balances[to] + amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    /// @dev Grants or revokes MINTER_ROLE
    function setupMinter(address minter, bool enabled) external onlyRole(ADMIN_ROLE) {
        require(minter != address(0), "!minter");
        if (enabled) _setupRole(MINTER_ROLE, minter);
        else _revokeRole(MINTER_ROLE, minter);
    }

    function removeBurner() external onlyRole(ADMIN_ROLE) {
        _revokeRole(BURNER_ROLE, msg.sender);
    }

    /// @dev Grants or revokes BURNER_ROLE
    function setupBurner(address burner, bool enabled) external onlyRole(ADMIN_ROLE) {
        require(burner != address(0), "!burner");
        if (enabled) _setupRole(BURNER_ROLE, burner);
        else _revokeRole(BURNER_ROLE, burner);
    }

    /// @dev Returns true if MINTER
    function isMinter(address minter) external view returns (bool) {
        return hasRole(MINTER_ROLE, minter);
    }

    /// @dev Returns true if BURNER
    function isBurner(address burner) external view returns (bool) {
        return hasRole(BURNER_ROLE, burner);
    }
}
