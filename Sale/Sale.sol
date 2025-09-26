// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract SuperStarTokenSale is Ownable {
    using SafeMath for uint256;

    IERC20 public starToken;
    uint256 public rate;
    address payable public wallet;

    bool public saleEnded;
    mapping(address => uint256) public purchasedTokens;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event SaleEnded();
    event TokensClaimed(address indexed buyer, uint256 tokensClaimed);

    modifier onlyWhenSaleActive() {
        require(!saleEnded, "Sale is not active");
        _;
    }

    constructor(address payable _wallet, IERC20 _starToken) Ownable(msg.sender) {
        require(_wallet != address(0), "Wallet address must not be zero");
        require(address(_starToken) != address(0), "Token address must not be zero");
        wallet = _wallet;
        starToken = _starToken;
        rate = 10000; // 1 ETH = 10,000 tokens
        saleEnded = false;
    }

    function depositTokens(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        starToken.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        starToken.transfer(msg.sender, _amount);
    }

    function endSale() external onlyOwner {
        require(!saleEnded, "Sale has already ended");
        saleEnded = true;
        emit SaleEnded();
    }

    function buyTokens() external payable onlyWhenSaleActive {
        uint256 ethAmount = msg.value;
        require(ethAmount > 0, "ETH amount must be greater than 0");

        uint256 tokens = ethAmount.mul(rate);
        require(starToken.balanceOf(address(this)) >= tokens, "Insufficient tokens for sale");
        
        purchasedTokens[msg.sender] = purchasedTokens[msg.sender].add(tokens);

        emit TokensPurchased(msg.sender, tokens);
    }

    function claimTokens() external {
        require(saleEnded, "Sale is not over yet");
        uint256 tokensToClaim = purchasedTokens[msg.sender];
        require(tokensToClaim > 0, "No tokens to claim");

        purchasedTokens[msg.sender] = 0;
        starToken.transfer(msg.sender, tokensToClaim);

        emit TokensClaimed(msg.sender, tokensToClaim);
    }

    function withdrawFunds() external onlyOwner {
        (bool success, ) = wallet.call{value: address(this).balance}("");
        require(success, "Failed to withdraw funds");
    }
}