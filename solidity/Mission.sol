pragma solidity ^0.5.0;

import "./Awards.sol";

contract Mission {
    string internal name;
    string internal description;
    
    address internal awardsAddr;

    Awards internal awards;
    mapping (address => bool) public signedUsers;
    
    constructor(string memory sourceName, string memory sourceDescription, address _addr) public {
        name = sourceName;
        description = sourceDescription;
        awardsAddr = _addr;
        awards = Awards(awardsAddr);
    }
    
    function getInfo() public view returns (string memory, string memory) {
        return (name, description);
    }
    
    
    function punch() public {
        require(signedUsers[msg.sender] == true);
        awards.sendAwardTo(msg.sender);
    }
	
	function signUp() public {
	    signedUsers[msg.sender] = true;
	}
	
	function quit() public {
	    require(signedUsers[msg.sender] == true);
	    delete signedUsers[msg.sender];
	}
	
	function string2bytes32(string memory source) internal pure returns (bytes32 result) {
	    assembly {
            result := mload(add(source, 32))
        }
        return result;
    }
}