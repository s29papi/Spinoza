const util = require("util");
const request = util.promisify(require("request"));
task(
    "register-sp",
    "Register Sp in spinoza"
  )
    .addParam("contract", "The address of the Spinoza contract")
    .addParam("minerid", "The miner id for the particular miner to perform this check on")
    .setAction(async (taskArgs) => {
        const contractAddr = taskArgs.contract
        const account = taskArgs.account
        const minerid = taskArgs.minerid
        const networkId = network.name
        console.log("checking miner", networkId)
        const Spinoza = await ethers.getContractFactory("SpinozaV0Lend")
  
        //Get signer information
        const accounts = await ethers.getSigners()
        const signer = accounts[0]

        const priorityFee = await callRpc("eth_maxPriorityFeePerGas")

        async function callRpc(method, params) {
            var options = {
              method: "POST",
              url: "https://api.hyperspace.node.glif.io/rpc/v1",
              
              headers: {
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                jsonrpc: "2.0",
                method: method,
                params: params,
                id: 1,
              }),
            };
            const res = await request(options);
            return JSON.parse(res.body).result;
          }

    

 



      const spinoza = new ethers.Contract(contractAddr, Spinoza.interface, signer)
      let result = await spinoza.registerAsSp(minerid,  {
        gasLimit: 3000000,
        maxPriorityFeePerGas: priorityFee
    })

     result = await result.wait()
     console.log(result)
    })










    
// compile = yarn hardhat compile
// deploy = yarn hardhat deploy
// task = yarn hardhat register-Sp --contract 0x7676f85A9dEcB4EF5bC11517538BD22dba7d15Ae  --minerid 01129