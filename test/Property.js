var Property = artifacts.require("./Property.sol");

contract("Checking Property", function(accounts){
	var propertyInstance;

	it('create a new user', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.addUser('me','45544','66545','se@gh.b', 7766777);
		});
	});

	it('Checks the correct mapping', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.getUserDetails(0xA21df31841Df52a48CE66bdA0d33037F7aeCFDBa);
		}).then(function(myUser){
			assert.equal(myUser[0], 'me', "correct ID");
			assert.equal(myUser[1], '45544', "correct name");
			// return propertyInstance.Users(1);
		});
	});
});