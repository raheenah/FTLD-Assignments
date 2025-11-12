
pragma solidity ^0.8.20;

contract Counter {
    uint256 private count;


    function increment() external {
        unchecked { count += 1; }
    }

    function decrement() external {
        require(count > 0, "Counter can not be less than zero");
        unchecked { count -= 1; }
    }

    function reset() external {
        count = 0;
    }


    function getCount() external view returns (uint256) {
        return count;
    }
}
