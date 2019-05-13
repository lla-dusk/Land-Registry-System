pragma solidity >=0.4.21 <0.6.0;

import "./Bank.sol";

contract Property {
	address payable admin;
	Bank public bankContract;
	
	struct User {
		string Name;
		string AdharNo;
		string PanNo;
		string email;
		string PhoneNo;
	}

	struct Land {
		address Owner;
		string ReraRegisteredNo;
		bool LandOnRoad;
		//string LandArea;
		string District;
		string State;
		uint256 Price;
	}

	uint256 public landCount = 0;

	mapping (address => User) public users; //user address => User struct
	address[] public userAcc; //stores address of every user added

	mapping (uint256 => Land) public userLands; //landId(i.e., landCount++) => Land struct
	uint256[] public lands; //stores rera registered number of every land added

	//rera registered number (its hash) => address of the owner requesting to buy the land
	mapping (uint256 => address) public landOwnerHistory;

	//rera registered number (its hash) => address of the owners
	mapping (uint256 => address) public landOwnerChangeRequest;

	//buyer address => loan amount
	mapping (address => mapping (uint256 => uint256)) public loan;

	event addUsers (address newUser);

	event addLands (
		uint256 _landId,
		string district,
		uint256 price
	);

	event changeOwnership (
		string _reraRegisteredNo, 
		address _oldOwner,
		address _newOwner
	);

	event Transaction (
		address sender,
		address receiver,
		uint256 value
	);

	modifier onlyOwner(uint256 _landId) { 
	 	require (userLands[_landId].Owner == msg.sender); 
		_; 
	}

	modifier verifiedByAdmin() { 
		require (msg.sender == admin); 
		_; 
	}
	
	constructor () public {
		admin = msg.sender;
	}

	bool duplicateUser = false;

	//adds msg.sender as the new user
	function addUser (string memory _name, string memory _adharNo, string memory _panNo, string memory _email, string memory _phoneNo) public returns(bool) {
		address _address = msg.sender;
		//checks for double registration
		checkForDuplicateUser (_adharNo);
		//procced only if the requested adahr number is not registered earlier
		require (duplicateUser == false);
		//data is mapped in the users mapping
		users[_address] = User(_name, _adharNo, _panNo, _email, _phoneNo);
		//address is stored in the user addresses array, userAcc
		userAcc.push(msg.sender);
		//shout out the address of the new user added
		emit addUsers(msg.sender);
		return true;
	}

	//checks the requested adhar number to avoid double registration of a single user
	function checkForDuplicateUser (string memory _adharNo) private {
		for(uint256 i=1; i<=userAcc.length; i++) {
			//checks if the aadhar number of the new requesting user is similar to any already registered user
			//eliminates double registration of the same individual
			if(uint(keccak256(abi.encodePacked(users[userAcc[i]].AdharNo))) == uint(keccak256(abi.encodePacked(_adharNo)))) {
				"User ID Already Exists!";
				duplicateUser = true;
			}
			duplicateUser = false;
		}
	}
	
	//users can be searched via their addresses
	//one user returned at a time
	function getUserDetails (address _address) public view returns(string memory, string memory, string memory) {
		return (users[_address].Name, users[_address].email, users[_address].PhoneNo);
	}

	//returns the user count and all the addresses of the users there in the platform
	function getAllUsers () public view returns (address[] memory, uint256) {
		return (userAcc, userAcc.length);
	}

	bool duplicateLand = false;

	//user can add new lands by calling this function, becoming the owner of the land
	function addLand (string memory _reraRegisteredNo, bool _landOnRoad, string memory _district, string memory _state, uint256 _price) public returns (bool) {
		landCount++;
		checkForDuplicateLand (_reraRegisteredNo);
		require (duplicateLand == false);
		//data is mapped to the userLands mapping, landId/landCount being the key
		userLands[landCount] = Land(msg.sender, _reraRegisteredNo, _landOnRoad, _district, _state, _price);
		//store the hash of the rera registered number in the lands array
		lands.push(uint(keccak256(abi.encodePacked(_reraRegisteredNo))));
		//shout out for every new land added
		emit addLands(landCount, _district, _price);
		//address of the owner mapped with the hash of the rera registered number (key)
		//this mapping has the history of the owners of a land
		landOwnerHistory[uint(keccak256(abi.encodePacked(_reraRegisteredNo)))] = msg.sender;
		return true;
	}

	function checkForDuplicateLand (string memory _reraRegisteredNo) private {
		for(uint256 i = 1; i <= lands.length; i++) {
			//checks if rera registered number of the new land requested is similar to any of the previous lands
			if(uint(keccak256(abi.encodePacked(userLands[lands[i]].ReraRegisteredNo))) == uint(keccak256(abi.encodePacked(_reraRegisteredNo)))) {
				"Land Already Exists!";
				duplicateLand = true;
			}
			duplicateLand = false;
		}
	}

	//returns the total land count and the array 'lands' giving the hash of all the rera registered numbers
	function getAllLands () public view returns (uint256[] memory, uint256) {
		return (lands, lands.length);
	}

	//any land can be searched using the landId and rera registered number of the land
	function getLandDetailsById (uint256 _landId, uint256 _reraRegisteredNo) public view returns(address, string memory, bool, string memory, string memory, uint256) {
		return (userLands[_landId].Owner, userLands[_landId].ReraRegisteredNo, userLands[_landId].LandOnRoad, userLands[_landId].District, userLands[_landId].State, userLands[_landId].Price);
	}

	//returns all the lands (number of lands and hash of the rera registered number) owned by the msg.sender
	function getLandDetails () public view returns(uint256, uint[] memory) {
		uint[] memory landIds;
		for(uint i = 0; i <= lands.length; i++){
			if(userLands[i].Owner == msg.sender){
				landIds[i] = uint(keccak256(abi.encodePacked(userLands[i+1].ReraRegisteredNo)));
			}
		}
		return (landIds.length, landIds);
	}

	//gets the balance of an address
	function getBalance(address addr) public view returns(uint256) {
        return addr.balance;
    }

	//address(0) = 0x0 => is used to check if the address is empty 
	function buyLand (uint256 _landId, bool _bankLoan) public payable {
		//new owner should not be the same old owner
		require (userLands[_landId].Owner != msg.sender);
		//no ownership change request must exist
		//require (landOwnerChangeRequest[uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))] == address(0));
		if (_bankLoan == true) { 
			"Tell the bank to pay";
			//calls for the transferLoan function in the Bank contract which transfers the amount
			bankContract.transferLoan(userLands[_landId].Price); 
			loan[msg.sender][uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))] = userLands[_landId].Price;
			emit Transaction (address(bankContract), admin, userLands[_landId].Price);
		}
		else {
			//buyer must have enuf balance to pay to the seller
			//msg.value will be send to the contract address
			require (userLands[_landId].Price  <= getBalance(msg.sender));
			require (msg.value == userLands[_landId].Price);
			emit Transaction (msg.sender, admin, userLands[_landId].Price);
		}
		//ownership change is requested in the mapping
		landOwnerChangeRequest[uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))] = msg.sender;
	}

	//returns the addresses of all the buyers interested in buying a particular land
	function displayBuyers (string memory _reraRegisteredNo) public view returns (uint256, address[] memory) {
		address[] memory buyers;
		for (uint i = 0; i <= userAcc.length; i++) {
			//checks for the user address requested for buying that particular land
			if (userAcc[i] == landOwnerChangeRequest[uint(keccak256(abi.encodePacked(userLands[i+1].ReraRegisteredNo)))]) {
				buyers[i] = userAcc[i];
			} 
		}
		return (buyers.length, buyers);
	}

	function changeLandOwner (uint256 _landId, address _newOwner) onlyOwner(_landId) public {
		//ownership change request must exist
		require (landOwnerChangeRequest[uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))] != address(0));
		//transfer coins from contract to seller
		//uint160 is used to explicitly convert the address as payable
		address(uint160(msg.sender)).transfer(userLands[_landId].Price);
		emit Transaction (admin, msg.sender, userLands[_landId].Price);
		//admin, i.e., the government approves the change of ownership;
		govSignOwnership(userLands[_landId].ReraRegisteredNo, userLands[_landId].Owner, _newOwner);
		//transfers the ownership to the buyer
		userLands[_landId].Owner = landOwnerChangeRequest[uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))];
		refund(_landId);
		//empty the owner change request
		landOwnerChangeRequest[uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))] = address(0);	
	}

	//approves the land ownership change and stores the ownership history in the mapping
	function govSignOwnership (string memory _reraRegisteredNo, address _owner, address _newOwner) private {
		emit changeOwnership (_reraRegisteredNo, _owner, _newOwner);
		landOwnerHistory[uint(keccak256(abi.encodePacked(_reraRegisteredNo)))] = _newOwner;
	}

	function refund (uint256 _landId) private {
		//refunds the money to all the other buyers who requested to buy the land
		for (uint i = 0; i <= userAcc.length; i++) {
			//checks for the user address requested for buying that particular land
			if (userAcc[i] == landOwnerChangeRequest[uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))] && userAcc[i] != userLands[_landId].Owner) {
				address(uint160(userAcc[i])).transfer(userLands[_landId].Price);
			} 
		}
	}

	//returns the Ownership history of a land
	//returns the number of previous owners and their addresses
	function landOwnershipHistory (string memory _reraRegisteredNo, uint256 _landId) public returns (uint256, address[] memory) {
		address[] memory history;
		uint256 count = 0;
		for (uint256 i = 0; i <= lands.length; i++) {
			if (uint(keccak256(abi.encodePacked(_reraRegisteredNo))) == uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))) {
				count++;
				history[i] = userLands[_landId].Owner;
			}		
		}
		return (count, history);
	}

	//only the land owner can call this function if he wants to change the price of the land
	function changeLandPrice (uint256 _landId, uint256 _newPrice) onlyOwner(_landId) public returns(bool) {
	 	//no ownership change request must exist
	 	require (landOwnerChangeRequest[uint(keccak256(abi.encodePacked(userLands[_landId].ReraRegisteredNo)))] == address(0));
	 	userLands[_landId].Price = _newPrice;
	 	return true;
	 }

	function getLandByPriceRange (uint256 _priceA, uint256 _priceB) public view returns(uint256, uint[] memory) {
		uint256 count = 0;
		uint[] memory landIds;
		for (uint256 i = 0; i <= lands.length; i++) { 
			if (userLands[i].Price >= _priceA && userLands[i].Price <= _priceB) {
				count++;
				landIds[i] = uint(keccak256(abi.encodePacked(userLands[i+1].ReraRegisteredNo)));
			}
		}
		return (count, landIds);
	}	

	/*function getLandByLandArea (string memory _landArea) public view returns(uint256) {
		uint256 count = 0;
		for (uint256 i = 1; i <= lands.length; i++) { 
			if (uint(keccak256(abi.encodePacked(userLands[i].LandArea))) == uint(keccak256(abi.encodePacked(_landArea)))) {
				count++;
				//return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);
			}
		}
		return count;
	}*/

	/*function getLandByDistrict (string memory _district) public view returns(uint256) {
		uint256 count;
		for (uint256 i = 1; i <= lands.length; i++) { 
			if (uint(keccak256(abi.encodePacked(userLands[i].District))) == uint(keccak256(abi.encodePacked(_district)))) {
				count++;
				//return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);
			}
		}
		return count;
	}*/

	/*function getLandByLandOnRoad (uint256[] lands) public view returns(uint256/*, uint256[]) {
		uint256 count;
		for (uint256 i = 1; i <= lands.length; i++) { 
			if (userLands[i].LandOnRoad == true) {
				count++;
				//return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);
			}
		}
		return count;
	}*/
	
}
//uint(keccak256(abi.encodePacked(land.LandOnRoad)))

