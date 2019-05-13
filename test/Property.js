const Property = artifacts.require("./Property.sol")
//const rera = accounts[2]
const users = new Array()

contract('Property', (accounts) => {
	before(async () => {
		this.property = await Property.deployed()
	})

	it('contract is successfully deployed', async () => {
		const address = await this.property.address
		assert.notEqual(address, 0x0)
		assert.notEqual(address, '')
		assert.notEqual(address, null)
		assert.notEqual(address, undefined)
	})

	it('adds users', async () => {
		const newUser = await this.property.addUser('Sneha', '1111', '2222', 'sneha@email.com', '98765', { from: accounts[1] })
		const user = await this.property.users(accounts[1])
		const event = newUser.logs[0].args
		assert.equal(event.newUser, accounts[1])
		users[0] = accounts[1]
		assert.equal(users[0], accounts[1], "correct address")
		console.log(users)
	})

	it('adds another users', async () => {
		const newUser = await this.property.addUser('Snehal', '11110', '22220', 'snehal@email.com', '987654', { from: accounts[3] })
		const user = await this.property.users(accounts[3])
		const event = newUser.logs[0].args
		assert.equal(event.newUser, accounts[3])
		users[1] = accounts[3]
		assert.equal(users[1], accounts[3], "correct address")
		console.log(users)
	})

	it('check user mapping', async () => {
		const user = await this.property.users(accounts[1])
		assert.equal(user.Name, 'Sneha', "correct name")
		assert.equal(user.AdharNo, '1111', "correct aadhar number")
		assert.equal(user.PanNo, '2222', "correct pan number")
		assert.equal(user.email, 'sneha@email.com', "correct email")
		assert.equal(user.PhoneNo, '98765', 'correct phone number')
		//assert.equal(users[0], accounts[1], "correct address")
	})

	it('adds land', async () => {
		const newLand = await this.property.addLand('999-999', true, 'Kolkata', 'WB', 10, { from: accounts[1] })
		const landCount = await this.property.landCount()
		assert.equal(landCount, 1)
		const event = newLand.logs[0].args
		assert.equal(event._landId.toNumber(), 1, "correct land id")
		const lands = await this.property.userLands(landCount)
		const landArr = new Array()
		landArr[0] = lands
		console.log(landArr)
	})

	it('check land mapping', async () => {
		const landCount = await this.property.landCount()
		const land = await this.property.userLands(landCount)
		assert.equal(land.Owner, accounts[1], "correct owner")
		assert.equal(land.ReraRegisteredNo, '999-999', "correct rera id")
		assert.equal(land.LandOnRoad, true, "correct feature")
		//assert.equal(land.LandArea, 'Salt Lake', "correct area")
		assert.equal(land.District, 'Kolkata', "correct district")
		assert.equal(land.State, 'WB', "correct state")
		assert.equal(land.Price.toNumber(), 10, "correct price")
	})

	it('buy land', () => {
		const landCount = this.property.landCount()
		const buy = this.property.buyLand(landCount, false, { from: accounts[3] })
		.then(function(event) {
			assert(event.logs[0].args)
			return this.property.transaction(accounts[3],address[0])
		})
		.then(function(txn) {
			assert.equal(txn[0], 10, "correct amount send")	
			return this.property.landOwnerChange(landCount)		
		})
		.then(function(change) {
			assert.equal(change[0], accounts[3])
		})
	})

})