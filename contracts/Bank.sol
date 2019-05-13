pragma solidity >=0.4.21 <0.6.0;

contract Bank {
	uint256 public bankCount = 0;
	uint256 public loanCount = 0;

	struct bank {
	 	string bankName;
	 	address bankAddr;
	}

	mapping (uint256 => bank) banks;
	mapping (uint256 => mapping (address => uint256)) loanAmount; //bank address to loan amount

	address[] allBanks;

	event bankAdded(
		uint256 bankId,
		string bankName
	);

	/*constructor () public {
		admin = msg.sender;
		//addBank('State Bank of India');
	}*/

	function addBank (string memory _bankName) public {
		bankCount++;
		banks[bankCount] = bank(_bankName, msg.sender);
		allBanks.push(msg.sender);
		emit bankAdded(bankCount, _bankName);
	}

	function getAllBanks () public view returns (address[] memory, uint256) { //user count and all user addresses
		uint256 count = 0;
		for(uint256 i = 1; i <= allBanks.length; i++) {
			count++;
		}
		return (allBanks, count);
	}

	function getBalance(address addr) public view returns(uint256) {
        return addr.balance;
    }

	function transferLoan (uint256 _value) public payable {
		require (getBalance(msg.sender) >= _value);
		require (msg.value == _value);
		loanCount++;
		loanAmount[loanCount][msg.sender] = _value;
	}

}