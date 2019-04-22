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
    App.contracts.Property.deployed().then(function(instance){
      PropertyInstance = instance;

      return App.getUser();
      
    //  return PropertyInstance.addUser(ID, name, age, add);
     // return PropertyInstance.addUser(ID, name, age, add);
    });
  },
//   user: function(){
//     var id = $('#id').val();
//     var candidate = $('#name').val();
//     var age = $('#age').val();
//     var add = $('#add').val()
//     console.log("id is: " + id + "your Name is: " + candidate + 'age is: ' + age + "add is: " + add);
// App.contracts.Property.deployed().then(function(instance){
//   var rtrn = instance.addUser(id, candidate, age, add);
//   // if(rtrn == true){
//     document.myForm.action = "new.html";
//   // }
// });
//   },
  getUser: function(){
    // var id = $('#srchID').val();
    // var table = $('#table');
  //  var id=data.ID;
  var table = $('#table');
  var url = document.location.href,
        params = url.split('?')[1].split('&'),
        data = {}, tmp;
    for (var i = 0, l = params.length; i < l; i++) {
         tmp = params[i].split('=');
         data[tmp[0]] = tmp[1];
    }
    document.getElementById('here').innerHTML = data.ID + data.firstname;
    console.log(data.ID);

    var id= data.ID;
    App.contracts.Property.deployed().then(function(instance){
      return instance.getUserDetails();
    }).then(function(res,err){
      if(res){
        console.log(res);
        var tbl_tmplt = "<tr><td>" + id  +"</td><td>" + res[0] + "</td><td>" + res[1] + "</td><td>" + res[2] + "</td></tr>";
        table.append(tbl_tmplt);
      } 
      else
      {
         console.log(res);
        var tbl_tmplt = "<tr><td>" + id +"Doesn't exist" + "</td></td>";
        table.append(tbl_tmplt);
      }
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
