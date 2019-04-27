var Property = artifacts.require("./Property.sol");

contract("Checking Property", function(accounts){
	var propertyInstance;

	it('create a new user', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.addUser('me','45544','66545','se@gh.b', '7766777');
		});
	});

	it('create a new land', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.addLand('9876', true, 'area', 'district', 'state', '2222');
		});
	});

	it('Checks the correct mapping', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.getUserDetails('0xA21df31841Df52a48CE66bdA0d33037F7aeCFDBa');
		}).then(function(myUser){
			assert.equal(myUser[0], 'me', "correct name");
			assert.equal(myUser[1], 'se@gh.b', "correct email");
			assert.equal(myUser[2], '7766777', "correct phone number");
			// return propertyInstance.Users(1);
		});
	});

	it('Checks the correct mapping of land', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.getLandByPrice(2222);
		}).then(function(myland){
			assert.equal(myland[0], 'me', "correct owner");
			assert.equal(myland[1], '9876', "correct name");
			assert.equal(myland[2], true, "rera verified");
			assert.equal(myland[3], 'area', "correct area");
			assert.equal(myland[4], 'district', "correct district");
			assert.equal(myland[5], 'state', "correct state");
			assert.equal(myland[6], '2222', "correct price");
			// return propertyInstance.Users(1);
		});
	});
});
