pragma solidity >=0.4.21 <0.6.0;

contract Property {
	//UIDAI - Unique Identification Authority of India
	address public admin;
	//address public Uidai;
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
		string ReraRegisteredNo;
		bool LandOnRoad;
		string LandArea;
		string District;
		string State;
		string Price;
	}

	uint256 public landCount = 0;

	mapping (address => User) users;
	address[] public userAcc;

	mapping (uint256 => Land) userLands;
	uint256[] public lands;

	mapping (uint256 => address) landOwnerChange;

	mapping (uint256 => bool) verifiedLands;

	mapping (address => uint256) balanceOf;

	event addUsers (address newUser);

	event addLands (uint256 indexed _landId);

	event Transfer(
		address indexed _from, 
		address indexed _to,
		uint256 _value);

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
		/*user.Name = _name;
		user.AdharNo = _adharNo;
		user.PanNo = _panNo;
		user.email = _email;
		user.PhoneNo = _phoneNo;*/
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

	function getAllUsers () public view returns (address[] memory) {
		return userAcc;
	}

	function addLand (string memory _reraRegisteredNo, bool _landOnRoad, string memory _landArea, string memory _district, string memory _state, string memory _price) public returns (bool) {
		landCount++;
		/*Land memory land = userLands[landCount];
		land.currOwner = msg.sender;
		land.verifiedByRera = false;
		land.LandOnRoad = _landOnRoad;
		land.ProposedLandUse = _proposedLandUse;
		land.LandArea = _landArea;
		land.Jurisdiction = _jurisdiction;
		land.LocalBodyName = _localBodyName;
		land.Plot = _plot;
		land.Khatian = _khatian;
		land.District = _district;
		land.Thana = _thana;
		land.LocalBody = _localBody;
		land.Price = _price;*/
		userLands[landCount] = Land(msg.sender, _reraRegisteredNo, _landOnRoad, _landArea, _district, _state, _price);
		lands.push(landCount) -1;
		emit addLands(landCount);
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
	function changeLandOwner (uint256 _landId, address _newOwner) onlyOwner(_landId) public returns(bool) {
		//new owner should not be the same old owner
		require (userLands[_landId].Owner != _newOwner);
		//no ownership change request must exist
		require (landOwnerChange[_landId] == address(0));
		//ownership change is requested
		landOwnerChange[_landId] = _newOwner;
		return true;
	}

	function approveChangeOwner (uint256 _landId) verifiedByAdmin public returns(bool) {
		//ownership change request must exist
		require (landOwnerChange[_landId] != address(0));
		userLands[_landId].Owner = landOwnerChange[_landId];
		//empty the owner change request
		landOwnerChange[_landId] = address(0);
		return true;
	}

	function transfer (address _to, uint256 _value) public returns(bool) {
		//exception of account doesn't have enuf
		require(balanceOf[msg.sender] >= _value); 
		//runs the code below only if require is true
		//transfer the balance
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		//transfer event
		emit Transfer(msg.sender, _to, _value);
		//return boolean
		return true;
	}
	

	function changeLandPrice (uint256 _landId, string memory _newPrice) onlyOwner(_landId) public returns(bool) {
		//no ownership change request must exist
		require (landOwnerChange[_landId] == address(0));
		userLands[_landId].Price = _newPrice;
		return true;
	}
	
	function getLandDetails () public view returns(address, string memory, bool, string memory, string memory, string memory, string memory) {
		for(uint i=1;i<=lands.length;i++){
			if(userLands[i].Owner == msg.sender){
				return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);
			}
		}
	}

	function getLandByPrice (uint256 _price) public view returns(address, string memory, bool, string memory, string memory, string memory, string memory) {
		for (uint256 i = 1; i <= lands.length; i++) { 
			if (uint(keccak256(abi.encodePacked(userLands[i].Price))) == uint(keccak256(abi.encodePacked( _price)))) {
				return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);

			}
		}
	}	

	function getLandByLandArea (string memory _landArea) public view returns(address, string memory, bool, string memory, string memory, string memory, string memory) {
		for (uint256 i = 1; i <= lands.length; i++) { 
			if (uint(keccak256(abi.encodePacked(userLands[i].LandArea))) == uint(keccak256(abi.encodePacked(_landArea)))) {
				return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);
			}
		}
	}

	function getLandByDistrict (string memory _district) public view returns(address, string memory, bool, string memory, string memory, string memory, string memory) {
		for (uint256 i = 1; i <= lands.length; i++) { 
			if (uint(keccak256(abi.encodePacked(userLands[i].District))) == uint(keccak256(abi.encodePacked(_district)))) {
				return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);
			}
		}
	}

	function getLandByLandOnRoad () public view returns(address, string memory, bool, string memory, string memory, string memory, string memory) {
		for (uint256 i = 1; i <= lands.length; i++) { 
			if (userLands[i].LandOnRoad == true) {
				return (userLands[i].Owner, userLands[i].ReraRegisteredNo, userLands[i].LandOnRoad, userLands[i].LandArea, userLands[i].District, userLands[i].State, userLands[i].Price);
			}
		}
	}
	
}
//uint(keccak256(abi.encodePacked(land.LandOnRoad)))

