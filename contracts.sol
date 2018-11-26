pragma solidity ^0.5.0;

contract Awards {
    struct Award {
        uint32 tree;
        uint32 flower;
        uint32 dog;
    }
    
    address internal founder;
    
    mapping (address => Award) internal userAwards;
    
    modifier onlyFounder () {
        require (msg.sender == founder);
        _;
    }
    
    function retriveAwards() public view returns (uint32, uint32, uint32) {
        return (userAwards[msg.sender].tree, 
                userAwards[msg.sender].flower,
                userAwards[msg.sender].dog);
    }
    
    function sendAwardTo(address user) internal onlyFounder() {
        uint256 r = fakeRandom();
	    if (r % 10 < 5) {
	        // send a tree, 50%
	        // record it in the mapping, for now
	        // later we will implement a ERC721 interface
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
        uint256 r = uint256(keccak256(abi.encodePacked(msg.sender))) + 
	                    uint256(keccak256(abi.encodePacked(now)));
	    return r;
    }
}

/// 每日打卡
contract DailyPunch is Awards {
	struct Mission {
		bytes32 name;
		string description;
	}
	
    // 任务列表
    Mission[] public missions;
    
	// 用户报名任务
	mapping (address => mapping (uint256 => bool)) entryForm;
	
	// 名字索引 
	mapping (bytes32 => uint256[]) nameIndex;
	
	// 发送任务建立的信息
	event missionEstablished(uint256, string, string, uint256);
	// 发送打卡信息 
	event punchEvent(uint256 missionId, address user);
	
	constructor () public payable {
	    founder = msg.sender;
	}
	
	// 创建一个任务
	function establishAMission (string memory sourceName, string memory description) 
	public returns(uint256) {
	    bytes32 name = string2bytes32(sourceName);
	    Mission memory _mission = Mission({
	        name : name,
		    description: description
	    });
        uint256 missionId = uint256(missions.push(_mission)) - 1;
        nameIndex[name].push(missionId);
		return missionId;
	}
	
	// 报名一个任务
	function signUp (uint256 missionId) public {
	    address user = msg.sender;
		entryForm[user][missionId] = true;
	}
	
	// 退出一个任务
    function signOut(uint256 missionId) public {
        address user = msg.sender;
        entryForm[user][missionId] = false;
    }
	
	// 打卡
	function punch (uint256 missionId) public {
        address user = msg.sender;
		require (entryForm[user][missionId], "Please sign up first.");
		sendAwardTo(user);
	}
	
    function searchMissionByName(string memory sourceName) public view returns (uint256[] memory) {
        bytes32 name = string2bytes32(sourceName);
        return nameIndex[name];
    }
    
    function string2bytes32(string memory source) internal pure returns (bytes32 result) {
	    assembly {
            result := mload(add(source, 32))
        }
        return result;
    }
}
