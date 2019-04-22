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
		uint PhoneNo;
	}

	struct Land {
		address currOwner;
		bool verifiedByRera;
		bool LandOnRoad;
		string ProposedLandUse;
		string LandArea;
		string Jurisdiction;
		string LocalBodyName;
		string Plot;
		string Khatian;
		string District;
		string Thana;
		string LocalBody;
		uint Price;
	}

	uint public landCount = 0;

	mapping (address => User) users;
	address[] public userAcc;

	mapping (uint => Land) userLands;
	uint[] public lands;

	mapping (uint => address) landOwnerChange;

	mapping (uint => bool) verifiedLands;

	mapping (address => uint256) balanceOf;

	event addUsers (address newUser);

	event addLands (uint indexed _landId);

	event Transfer(
		address indexed _from, 
		address indexed _to,
		uint256 _value);

	modifier onlyOwner(uint _landId) { 
	 	require (userLands[_landId].currOwner == msg.sender); 
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

	function addUser (address _address, string memory _name, string memory _adharNo, string memory _panNo, string memory _email, uint _phoneNo) public returns(bool) {
		User memory user = users[_address];
		for(uint i=1; i<=userAcc.length; i++) {
			if(uint(keccak256(abi.encodePacked(_adharNo))) == uint(keccak256(abi.encodePacked(user.AdharNo)))) {
				"User ID Already Exists!";
				return false;
			}
		}
		user.Name = _name;
		user.AdharNo = _adharNo;
		user.PanNo = _panNo;
		user.email = _email;
		user.PhoneNo = _phoneNo;
		userAcc.push(_address) -1;
		emit addUsers(_address);
		return true;
	}

	function getUserCount () public view returns(uint) {
		return userAcc.length;
	}
	
	function getUserDetails (address _address) public view returns(string memory, string memory, uint) {
		return (users[_address].Name, users[_address].email, users[_address].PhoneNo);
	}

	function getAllUsers () public view returns (address[] memory) {
		return userAcc;
	}

	function addLand (bool _landOnRoad, string memory _proposedLandUse, string memory _landArea, string memory _jurisdiction, string memory _localBodyName, string memory _plot, string memory _khatian, string memory _district, string memory _thana, string memory _localBody, uint _price) public returns (bool) {
		landCount++;
		Land memory land = userLands[landCount];
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
		land.Price = _price;
		lands.push(landCount) -1;
		emit addLands(landCount);
		return true;
	}

	function approveLand (uint _landId) byRera public returns(bool) {
		//require (userLands[_landId].currOwner != msg.sender);
		userLands[_landId].verifiedByRera = true;
		verifiedLands[_landId] = true;
		return true;
	}
	

	function getLandCount () public view returns(uint) {
		return lands.length;
	}

	//address(0) = 0x0 => is used to check if the address is empty 
	function changeLandOwner (uint _landId, address _newOwner) onlyOwner(_landId) public returns(bool) {
		//new owner should not be the same old owner
		require (userLands[_landId].currOwner != _newOwner);
		//no ownership change request must exist
		require (landOwnerChange[_landId] == address(0));
		//ownership change is requested
		landOwnerChange[_landId] = _newOwner;
		return true;
	}

	function approveChangeOwner (uint _landId) verifiedByAdmin public returns(bool) {
		//ownership change request must exist
		require (landOwnerChange[_landId] != address(0));
		userLands[_landId].currOwner = landOwnerChange[_landId];
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
	

	function changeLandPrice (uint _landId, uint _newPrice) onlyOwner(_landId) public returns(bool) {
		//no ownership change request must exist
		require (landOwnerChange[_landId] == address(0));
		userLands[_landId].Price = _newPrice;
		return true;
	}
	

	function getLandByPrice (uint _price) public view returns(uint[] memory) {
		Land memory land;
		for (uint i = 1; i <= lands.length; i++) { 
			if (land.Price == _price) {
				return lands;
			}
		}
	}	

	function getLandByLandArea (string memory _landArea) public view returns(uint[] memory) {
		Land memory land;
		for (uint i = 1; i <= lands.length; i++) { 
			if (uint(keccak256(abi.encodePacked(land.LandArea))) == uint(keccak256(abi.encodePacked(_landArea)))) {
				return lands;
			}
		}
	}

	function getLandByDistrict (string memory _district) public view returns(uint[] memory) {
		Land memory land;
		for (uint i = 1; i <= lands.length; i++) { 
			if (uint(keccak256(abi.encodePacked(land.District))) == uint(keccak256(abi.encodePacked(_district)))) {
				return lands;
			}
		}
	}

	function getLandByLandOnRoad (string memory _landOnRoad) public view returns(uint[] memory) {
		Land memory land;
		for (uint i = 1; i <= lands.length; i++) { 
			if (uint(keccak256(abi.encodePacked(land.LandOnRoad))) == uint(keccak256(abi.encodePacked(_landOnRoad)))) {
				return lands;
			}
		}
	}
	
}


