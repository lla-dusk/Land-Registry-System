var Property = artifacts.require("./Property.sol");

contract("Property", function(accounts){
	var propertyInstance;
	var userAcc = new Array();
	var lands = new Array();
	var landCount = 0;

	it('create a new user', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			userAcc[0] = "0xEd37189229E6252048702dc747CBcd57cB8e44ed";
			return propertyInstance.addUser('me','45544','66545','se@gh.b', '7766777');
		});
	});

	it('create a new land', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			lands[1] = 1
			return propertyInstance.addLand('9876', true, 'area', 'district', 'state', 2222, {from: userAcc[0]});
		});
	});

	it('Checks the user mapping', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.getUserDetails('0xEd37189229E6252048702dc747CBcd57cB8e44ed');
		}).then(function(myUser){
			assert.equal(myUser[0], 'me', "correct name");
			assert.equal(myUser[1], 'se@gh.b', "correct email");
			assert.equal(myUser[2], '7766777', "correct phone number");
			/*return propertyInstance.getUserDetails('0x0708c57Bf78180e2DFA629A043e5CA10dCcd2f85');
		}).then(function(myUser){
			assert.equal(myUser[0], 'he', "correct name");
			assert.equal(myUser[1], 'sd@gh.b', "correct email");
			assert.equal(myUser[2], '7786777', "correct phone number");*/
		});
	});

	it('Checks the land mapping', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			landCount++;
			landId = 1;
			return propertyInstance.getLandDetailsById(landId);
		}).then(function(myland){
			assert.equal(myland[0], userAcc[0], "correct owner");
			assert.equal(myland[1], 1, "correct land id");
			assert.equal(myland[2], '9876', "correct name");
			assert.equal(myland[3], true, "rera verified");
			assert.equal(myland[4], 'area', "correct area");
			assert.equal(myland[5], 'district', "correct district");
			assert.equal(myland[6], 'state', "correct state");
			assert.equal(myland[7], 2222, "correct price");
		});
	});

	it('returns user count', function() {
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			userCount = 1;
			return propertyInstance.getUserCount();
		}).then(function(count){
			assert.equal(count, userCount);
		})
	});

	it('returns all users', function() {
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			userCount = 1;
			return propertyInstance.getAllUsers();
		}).then(function(userAcc){
			console.log(userAcc, userCount);
		});
	});

	it('change land price', function(){
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			landId = 1;
			newPrice = '999777';
			return propertyInstance.changeLandPrice(landId, newPrice, {from: '0xEd37189229E6252048702dc747CBcd57cB8e44ed'});
		}).then(function(bool){
			assert(bool, "true");
		});
	});

	it('returns all lands', function() {
		return Property.deployed().then(function(instance){
			propertyInstance = instance;
			return propertyInstance.getAllLands();
		}).then(function(lands){
			console.log(lands, landCount);
		});
	});

	it('returns an owner lands count', function() {
		return Property.deployed().then(function(instance) {
			propertyInstance = instance;
			return propertyInstance.getLandDetails({from: "0xEd37189229E6252048702dc747CBcd57cB8e44ed"});
		}).then(function(count, landArr) {
			assert.equal(count, landCount);
			assert.equal(landArr, lands);
			console.log(landCount);
			console.log(lands);
		});
	});

	it('return number of lands by price', function() {
		return Property.deployed().then(function(instance) {
			propertyInstance = instance;
			return propertyInstance.getLandByPrice('2222');
		}).then(function(count) {
				assert.equal(count[0], '9876', "land with same price");
				assert.equal(count[1], '2222', "land with same price");
			
		});
	});

});
