pragma solidity ^0.5.0;

contract Awards {
    struct Award {
        uint32 tree;
        uint32 flower;
        uint32 dog;
    }
    
    mapping (address => Award) internal userAwards;

    function retriveAwards(address user) public view returns (uint32, uint32, uint32) {
        return (userAwards[user].tree, 
                userAwards[user].flower,
                userAwards[user].dog);
    }
    
    function sendAwardTo(address user) public {
        uint256 r = fakeRandom();
	    if (r % 10 < 5) {
	        // send a tree, 50%
	        userAwards[user].tree += 1;
	    } else if (r % 10 < 8) {
	        // send a flower, 30%
	        userAwards[user].flower += 1;
	    } else {
	        // send a small animal, 20%
	        userAwards[user].dog += 1;
	    }
    }
    
    // 伪随机数，应该挺随机的 
	function fakeRandom() view internal returns (uint256){
        uint256 r = uint256(keccak256(abi.encodePacked(msg.sender))) ^ 
	                    uint256(keccak256(abi.encodePacked(now)));
	    return r;
    }
}