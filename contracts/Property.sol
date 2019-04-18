pragma solidity >=0.4.21 <0.6.0;

contract Property {
	
	struct User {
		bytes32 Name;
		bytes32 AdharNo;
		bytes32 PanNo;
		bytes32 email;
		bytes32 PhoneNo;
	}

	struct Land {
		bool LandOnRoad;
		bytes32 ProposedLandUse;
		bytes32 LandArea;
		bytes32 Jurisdiction;
		bytes32 LocalBodyName;
		bytes32 Plot;
		bytes32 Khatian;
		bytes32 District;
		bytes32 Thana;
		bytes32 LocalBody;
		bytes32 Price;
	}

	modifier onlyOwner(address _user) { 
		require (_user == msg.sender); 
		_; 
	}

	uint public landCount = 0;

	mapping (address => User) users;
	address[] public userAcc;

	mapping (address => mapping(uint => Land)) userLands;
	uint[] public lands;

	event addUsers (address newUser);

	event addLands (uint indexed _landId);

	function addUser (address _address, bytes32 _name, bytes32 _adharNo, bytes32 _panNo, bytes32 _email, bytes32 _phoneNo) public returns(bool) {
		User memory user = users[_address];
		for(uint i=1; i<=userAcc.length; i++) {
			if(_adharNo == user.AdharNo) {
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
	
	function getUserDetails (address _address) public view returns(bytes32, bytes32, bytes32) {
		return (users[_address].Name, users[_address].email, users[_address].PhoneNo);
	}

	function getAllUsers () public view returns (address[] memory) {
		return userAcc;
	}

	function addLand (bool _landOnRoad, bytes32 _proposedLandUse, bytes32 _landArea, bytes32 _jurisdiction, bytes32 _localBodyName, bytes32 _plot, bytes32 _khatian, bytes32 _district, bytes32 _thana, bytes32 _localBody, bytes32 _price) public onlyOwner(msg.sender) returns (bool) {
		landCount++;
		Land memory land = userLands[msg.sender][landCount];
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

	function getLandCount () public view returns(uint) {
		return lands.length;
	}

	function getLandByPrice (bytes32 _price) public view returns(uint[] memory) {
		Land memory land;
		for (uint i = 1; i <= lands.length; i++) { 
			if (land.Price == _price) {
				return lands;
			}
		}
	}	
}