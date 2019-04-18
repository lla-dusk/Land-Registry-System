var Property = artifacts.require("./Property.sol");

contract("Property", function(accounts){
	var propertyInstance;

	it('create a new user', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.addUser(44555, 'Shubham', 23, 'Jharkhand');
		}).then(function(receipt) {
			assert.equal(receipt.logs.length, 1, "an event was triggered");
			assert.equal(receipt.logs[0].event, "adduser", "the event type is correct");
			assert.equal(receipt.logs[0].args._id.toNumber(), 44555, "user id is correct");
			assert.equal(receipt.logs[0].args._name.toString(), "Shubham", "user name is correct");
			assert.equal(receipt.logs[0].args._age.toNumber(), 23, "user age is correct");
			assert.equal(receipt.logs[0].args._add.toString(), "Jharkhand", "user address is correct");
		});
	});

	it('Checks the correct mapping', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.getUsers(0);
		}).then(function(myUser){
			assert.equal(myUser[0], 44555, "correct ID");
			assert.equal(myUser[1], 'Shubham', "correct name");
			return propertyInstance.Users(1);
		});
	});
});