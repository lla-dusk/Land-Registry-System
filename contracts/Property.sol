pragma solidity >=0.4.21 <0.6.0;

contract Property {
	address public admin;
	address public Rera;
	
	struct User {
		string Name;
		string AdharNo;
		string PanNo;
		string email;
		string PhoneNo;
	}

	struct Land {
		address Owner;
		uint256 landId;
		string ReraRegisteredNo;
		bool LandOnRoad;
		string LandArea;
		string District;
		string State;
		uint256 Price;
	}

	struct Bank {
		string bankName;
		address addr;
	}

	uint256 loanId = 0;
	uint256 public landCount = 0;
	uint256 bankId = 0;

	mapping (address => User) public users;
	address[] public userAcc;

	mapping (uint256 => Land) public userLands;
	uint256[] public lands;

	mapping (uint256 => address) public landOwnerHistory;

	mapping (uint256 => address) public landOwnerChange;

	mapping (uint256 => bool) public verifiedLands;

	mapping (uint256 => Bank) public bank;
	address[] public banks;

	//sender to receiver to price
	mapping (address => mapping (address => uint256)) transaction;

	//mapping of loan id to user address to amount
	mapping (uint256 => mapping(address => uint256)) loan;
	
	//bank address to user address to loan amount approved success
	mapping (address => mapping(address => bool)) bankPayment;
	
	event addUsers (address newUser);

	event addLands (uint256 indexed _landId);

	event changeOwnership (uint256 indexed _landId, address _owner);

	modifier onlyOwner(uint256 _landId) { 
	 	require (userLands[_landId].Owner == msg.sender); 
		_; 
	}

	modifier verifiedByAdmin() { 
		require (msg.sender == admin); 
		_; 
	}
	
	modifier byRera() { 
		require (msg.sender == Rera); 
		_; 
	}
	
	constructor () public {
		admin = msg.sender;
		Rera = address(2);
	}

	function addUser (string memory _name, string memory _adharNo, string memory _panNo, string memory _email, string memory _phoneNo) public returns(bool) {
		address _address = msg.sender;
		for(uint256 i=1; i<=userAcc.length; i++) {
			if(uint(keccak256(abi.encodePacked(users[userAcc[i]].AdharNo))) == uint(keccak256(abi.encodePacked(_adharNo)))) {
				"User ID Already Exists!";
				return false;
			}
		}
		users[_address] = User(_name, _adharNo, _panNo, _email, _phoneNo);
		userAcc.push(msg.sender) -1;
		emit addUsers(msg.sender);
		return true;
	}

	function getUserCount () public view returns(uint256) {
		return userAcc.length;
	}
	
	function getUserDetails (address _address) public view returns(string memory, string memory, string memory) {
		return (users[_address].Name, users[_address].email, users[_address].PhoneNo);
	}

	function getAllUsers () public view returns (address[] memory, uint256) {
		uint256 count = 0;
		for(uint256 i = 1; i <= userAcc.length; i++){
			count++;
		}
		return (userAcc, count);
	}

	function addBank (address _addr, string memory _name) verifiedByAdmin public returns (bool) {
		bankId++;
		bank[bankId] = Bank(_name, _addr);
		banks.push(_addr);
		return true;
	}

	function addLand (string memory _reraRegisteredNo, bool _landOnRoad, string memory _landArea, string memory _district, string memory _state, uint256 _price) public returns (bool) {
		uint256 _landId = landCount++;
		userLands[_landId] = Land(msg.sender, _landId, _reraRegisteredNo, _landOnRoad, _landArea, _district, _state, _price);
		lands.push(_landId) -1;
		emit addLands(_landId);
		landOwnerHistory[_landId] = msg.sender;
		return true;
	}

	function approveLand (uint256 _landId) byRera public returns(bool) {
		//require (userLands[_landId].currOwner != msg.sender);
		//userLands[_landId].verifiedByRera = true;
		verifiedLands[_landId] = true;
		return true;
	}

	function getLandCount () public view returns(uint256) {
		return lands.length;
	}

	//address(0) = 0x0 => is used to check if the address is empty 
	function buyLand (uint256 _landId, bool _bankLoan, address _bankAddr) public payable {
		//new owner should not be the same old owner
		require (userLands[_landId].Owner != msg.sender);
		//no ownership change request must exist
		require (landOwnerChange[_landId] == address(0));
		if (_bankLoan == true) {
			"Tell the bank to pay";
			loanId++;
			loan[loanId][msg.sender] = userLands[_landId].Price;
			transferFromBank(_bankAddr, userLands[_landId].Price, msg.sender);
		}
		else {
			//buyer must have enuf balance to pay to the seller
			//msg.value will be send to the contract address
			require (userLands[_landId].Price  <= msg.sender.balance);
			transaction[msg.sender][address(this)] = userLands[_landId].Price;
		}
		//ownership change is requested
		landOwnerChange[_landId] = msg.sender;
	}

	function ChangeLandOwner (uint256 _landId, address _newOwner) onlyOwner(_landId) public {
		//ownership change request must exist
		require (landOwnerChange[_landId] != address(0));
		//transfer coins from contract to seller
		//uint160 is used to explicitly convert the address as payable
		address(uint160(msg.sender)).transfer(userLands[_landId].Price);
		transaction[address(this)][msg.sender] = userLands[_landId].Price;
		//transfers the ownership to the buyer
		userLands[_landId].Owner = landOwnerChange[_landId];
		//empty the owner change request
		landOwnerChange[_landId] = address(0);
		//admin, i.e., the government approves the change of ownership;
		approveOwnership(_landId, userLands[_landId].Owner);
	}

	modifier onlyBank(address _addr) { 
		for (uint i = 0; i <= banks.length; i++) {
			if (banks[i] == _addr) {
				_;
			}
		}
	}

	function transferFromBank (address _bankAddr, uint256 _value, address _user) onlyBank(_bankAddr) public payable {
		//wallet balance of the address is enuf
		require (_value <= _bankAddr.balance);
		//set ether payable to the contract is equal to the price of the land
		require (_value == msg.value);
		transaction[_bankAddr][address(this)] = _value;
		bankPayment[_bankAddr][_user] = true;
	}

	function approveOwnership (uint256 _landId, address _owner) verifiedByAdmin public returns (bool) {
		emit changeOwnership (_landId, _owner);
		landOwnerHistory[_landId] = _owner;
		return true;
	}

	function landOwnershipHistory (uint256 _landId) public returns (uint256, address[] memory) {
		address[] memory history;
		uint256 count = 0;
		for (uint256 i = 0; i <= lands.length; i++) {
			if (_landId == userLands[i].landId) {
				count++;
				history[i] = userLands[_landId].Owner;
			}		
		}
		return (count, history);
	}

	function changeLandPrice (uint256 _landId, uint256 _newPrice) onlyOwner(_landId) public returns(bool) {
	 	//no ownership change request must exist
	 	require (landOwnerChange[_landId] == address(0));
	 	userLands[_landId].Price = _newPrice;
	 	return true;
	 }

	function getLandDetailsById (uint256 _landId) public view returns(address, string memory, bool, string memory, string memory, string memory, uint256) {
		return (userLands[_landId].Owner, userLands[_landId].ReraRegisteredNo, userLands[_landId].LandOnRoad, userLands[_landId].LandArea, userLands[_landId].District, userLands[_landId].State, userLands[_landId].Price);
	}

	function getAllLands () public view returns (uint256[] memory, uint256) {
		uint256 count = 0;
		for(uint256 i = 1; i <= lands.length; i++){
			count++;
		}
		return (lands, count);
	}

	//owner's lands' count
	function getLandDetails () public view returns(uint256, uint[] memory) {
		uint256 count = 0;
		uint[] memory landIds;
		for(uint i=1;i<=lands.length;i++){
			if(userLands[i].Owner == msg.sender){
				count++;
				landIds[i] = userLands[i].landId;
			}
		}
		return (count, landIds);
	}

	function getLandByPrice (uint256 _price) public view returns(uint256, uint[] memory /*address, string memory, bool, string memory, string memory, string memory, string memory*/) {
		uint256 count = 0;
		uint[] memory landIds;
		for (uint256 i = 1; i <= lands.length; i++) { 
			if (userLands[i].Price == _price) {
				count++;
				//return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);
				landIds[i] = userLands[i].landId;
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

