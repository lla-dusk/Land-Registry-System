App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  hasVoted: false,

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Property.json", function(Property) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Property = TruffleContract(Property);
      // Connect provider to interact with contract
      App.contracts.Property.setProvider(App.web3Provider);

      return App.render();
    });
  },

  render: function() {

    var PropertyInstance;
  


    // var frm = document.getElementById("form1");
    // var ID = document.getElementById('ID').value;
    // var name = document.getElementById('name').value;
    // var age = document.getElementById('age').value;
    // var add = document.getElementById('add').value;

      //Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

    //Load contract data
    //  App.contracts.Property.deployed().then(function(instance){
    //    PropertyInstance = instance;
    //    instance.addUser('me','3333', '4444', 'em@fm.cm', 3333);
      
    // // //  return PropertyInstance.addUser(ID, name, age, add);
    // //  // return PropertyInstance.addUser(ID, name, age, add);
    // });
  },
  user: function(){
    var name = $('#name').val();
    var adhar = $('#adhar').val();
    var Pan = $('#Pan').val();
    var email = $('#email').val();
    var Phone = $('#Phone').val();
   console.log("id is: " + name + "your Name is: " + adhar + 'age is: ' + Pan + "add is: " + email + Phone);
  //  document.myForm.action = "new.html";
    //deploy on chain
App.contracts.Property.deployed().then(function(instance){
  var rtrn = instance.addUser(name, adhar, Pan,email, Phone);

//   if(rtrn == true){
//     document.myForm.action = "new.html";
//   }
//   else{
//     document.myForm.action = "new2.html"
//   }
 });
  },
};

$(function() {
  // $(window).load(function() {
    App.init();
  // });
});
