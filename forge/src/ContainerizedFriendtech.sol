// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/access/Ownable.sol";

contract ContainerizedFriendtech is Ownable {
    address public protocolFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public subjectFeePercent;

    uint256 public sharesSupply;

    event Trade(
        address trader,
        bool isBuy,
        uint256 shareAmount,
        uint256 ethAmount,
        uint256 protocolEthAmount,
        uint256 subjectEthAmount,
        uint256 supply
    );

    // Holder => Balance
    mapping(address => uint256) public sharesBalance;

    /**
     * @dev Sets the values for {protocolFeeDestination}, {protocolFeePercent}, and {subjectFeePercent}
     */
    constructor(address protocolFeeDestination_, uint256 protocolFeePercent_, uint256 subjectFeePercent_) {
        protocolFeeDestination = protocolFeeDestination_; // immutable once set
        protocolFeePercent = protocolFeePercent_; // immutable once set
        subjectFeePercent = subjectFeePercent_;
    }

    function setSubjectFeePercent(uint256 _feePercent) public onlyOwner {
        subjectFeePercent = _feePercent;
    }

    function getPrice(uint256 supply, uint256 amount) public pure returns (uint256) {
        uint256 sum1 = supply == 0 ? 0 : (supply - 1) * (supply) * (2 * (supply - 1) + 1) / 6;
        uint256 sum2 = supply == 0 && amount == 1
            ? 0
            : (supply - 1 + amount) * (supply + amount) * (2 * (supply - 1 + amount) + 1) / 6;
        uint256 summation = sum2 - sum1;
        return summation * 1 ether / 16000;
    }

    function getBuyPrice(uint256 amount) public view returns (uint256) {
        return getPrice(sharesSupply, amount);
    }

    function getSellPrice(uint256 amount) public view returns (uint256) {
        return getPrice(sharesSupply - amount, amount);
    }

    function getBuyPriceAfterFee(uint256 amount) public view returns (uint256) {
        uint256 price = getBuyPrice(amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        return price + protocolFee + subjectFee;
    }

    function getSellPriceAfterFee(uint256 amount) public view returns (uint256) {
        uint256 price = getSellPrice(amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        return price - protocolFee - subjectFee;
    }

    function buyShares(uint256 amount) public payable {
        require(sharesSupply > 0 || owner() == msg.sender, "Only the account owner can buy the first share");
        uint256 price = getPrice(sharesSupply, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        require(msg.value >= price + protocolFee + subjectFee, "Insufficient payment");
        sharesBalance[msg.sender] = sharesBalance[msg.sender] + amount;
        sharesSupply = sharesSupply + amount;
        emit Trade(msg.sender, true, amount, price, protocolFee, subjectFee, sharesSupply + amount);
        (bool success1,) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success2,) = payable(owner()).call{value: subjectFee}("");
        require(success1 && success2, "Unable to send funds");
    }

    function sellShares(uint256 amount) public payable {
        require(sharesSupply > amount, "Cannot sell the last share");
        uint256 price = getPrice(sharesSupply - amount, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        require(sharesBalance[msg.sender] >= amount, "Insufficient shares");
        sharesBalance[msg.sender] = sharesBalance[msg.sender] - amount;
        sharesSupply = sharesSupply - amount;
        emit Trade(msg.sender, false, amount, price, protocolFee, subjectFee, sharesSupply - amount);
        (bool success1,) = msg.sender.call{value: price - protocolFee - subjectFee}("");
        (bool success2,) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success3,) = payable(owner()).call{value: subjectFee}("");
        require(success1 && success2 && success3, "Unable to send funds");
    }
}
