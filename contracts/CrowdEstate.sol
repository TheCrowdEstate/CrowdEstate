// SPDX-License-Identifier: MIT
/**
 * @title CrowdEstate Contract
 * @author CrowdEstate Team
 */
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IErrors.sol";
import "./interfaces/IStructs.sol";
import "./PropertyToken.sol";

contract CrowdEstate is IErrors, IStructs, Ownable {
    mapping(uint256 => Property) public properties;
    mapping(uint256 => address) public tokens;

    // sellShare[msg.sender][_propertyId] = _amount
    mapping(address => mapping(uint256 => uint256)) public sellShare;

    uint256 public propertyCount;

    constructor() {
        propertyCount = 0;
    }

    /**
     * @notice Add a property to the market for investors to fund
     * @param _name The name of the property (Blackrock Manor)
     * @param _location The location of the property (1 Blackrock street)
     * @param _images An array of images showcasing the property
     * @param _shares The number of available shares to be offered which denotes the value of the property in ETH
     */
    function addProperty(
        string memory _name,
        string memory _location,
        string[] memory _images,
        uint256 _shares
    ) public {
        if (_shares <= 0) revert SharesMustBeGreaterThanZero();

        propertyCount++;

        Property storage newProperty = properties[propertyCount];
        newProperty.name = _name;
        newProperty.location = _location;
        newProperty.images = _images;
        newProperty.price = _shares;
        newProperty.shares = _shares;
        newProperty.soldShares = 0;

        PropertyToken newPropertyToken = new PropertyToken(
            _name,
            "PT",
            _shares
        );

        tokens[propertyCount] = address(newPropertyToken);
    }

    /**
     * @notice Buy a share of a property given a property id
     * @param _propertyId The id of the property
     */
    function buyShares(uint256 _propertyId) public payable {
        if (msg.value <= 0) revert AmountMustBeGreaterThanZero();
        if (_propertyId <= 0 || _propertyId > propertyCount)
            revert InvalidPropertyId();

        Property storage property = properties[_propertyId];

        if (property.soldShares + msg.value > property.shares)
            revert NotEnoughSharesAvailable();

        address tokenAddress = tokens[_propertyId];
        IERC20 token = IERC20(tokenAddress);

        token.transfer(msg.sender, msg.value);

        property.soldShares += msg.value;
        property.balances[msg.sender] += msg.value;
    }

    /**
     * @notice Sell your share of a property on the secondary market
     * @param _propertyId The id of the property
     * @param _share The amount of shares you want to sell
     */
    function secondarySellShare(uint256 _propertyId, uint256 _share) public {
        if (_share <= 0) revert SharesMustBeGreaterThanZero();
        if (_propertyId <= 0 || _propertyId > propertyCount)
            revert InvalidPropertyId();
        if (_share > properties[_propertyId].balances[msg.sender])
            revert InsufficientSharesBalance();

        properties[_propertyId].balances[msg.sender] -= _share;
        sellShare[msg.sender][_propertyId] += _share;

        address tokenAddress = tokens[_propertyId];
        IERC20 token = IERC20(tokenAddress);

        token.transferFrom(msg.sender, address(this), _share);
    }

    /**
     * @notice Cancel your secondary market sell for your shares
     * @param _propertyId The id of the property
     * @param _share The amount of shares you want to cancel
     */
    function cancelSecondarySellShare(
        uint256 _propertyId,
        uint256 _share
    ) public {
        if (_share <= 0) revert SharesMustBeGreaterThanZero();
        if (_propertyId <= 0 || _propertyId > propertyCount)
            revert InvalidPropertyId();
        if (_share > properties[_propertyId].soldShares)
            revert InsufficientSharesToCancel();

        properties[_propertyId].balances[msg.sender] += _share;
        sellShare[msg.sender][_propertyId] -= _share;

        address tokenAddress = tokens[_propertyId];
        IERC20 token = IERC20(tokenAddress);

        token.transfer(msg.sender, _share);
    }

    /**
     * @notice Buy a share of a property on the secondary market
     * @param _propertyId The id of the property
     * @param _share The amount of shares you want to buy
     */
    function secondaryBuyShare(
        uint256 _propertyId,
        uint256 _share
    ) public payable {
        if (_share <= 0) revert SharesMustBeGreaterThanZero();
        if (_propertyId <= 0 || _propertyId > propertyCount)
            revert InvalidPropertyId();
        if (msg.value <= 0) revert AmountMustBeGreaterThanZero();
        if (msg.value != _share) revert SentAmountDoesNotMatchShare();

        Property storage property = properties[_propertyId];

        address tokenAddress = tokens[_propertyId];
        IERC20 token = IERC20(tokenAddress);

        token.transfer(msg.sender, msg.value);

        property.balances[msg.sender] += _share;
    }

    /**
     * @notice Withdraw the ETH in the smart contract
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        if (balance <= 0) revert NoBalanceToWithdraw();

        payable(msg.sender).transfer(balance);
    }

    /**
     * @notice View the amount of sold property shares
     * @param _propertyId The id of the property
     */
    function soldPropertyShares(
        uint256 _propertyId
    ) public view returns (string memory) {
        if (_propertyId <= 0 || _propertyId > propertyCount)
            revert InvalidPropertyId();

        Property storage property = properties[_propertyId];

        uint256 percentage = (property.soldShares * 10000) / property.shares;

        string memory integerPart = uint256ToString(percentage / 100);
        string memory decimalPart = uint256ToString(percentage % 100);

        string memory result = string(
            abi.encodePacked(integerPart, ".", decimalPart, "%")
        );

        return result;
    }

    function uint256ToString(
        uint256 value
    ) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
