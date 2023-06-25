import {Web3Connection, ERC20} from '@taikai/dappkit';

const connection = new Web3Connection({ web3Host: process.env.WEB3_HOST_PROVIDER });

await connection.start(); // start web3 connection so assignments are made
await connection.connect(); // connect web3 by asking the user to allow the connection (this is needed for the user to _interact_ with the chain)

const erc20Deployer = new ERC20(connection);
await erc20Deployer.loadAbi(); // load abi contract is only needed for deploy actions

const tx =
  await erc20Deployer.deployJsonAbi(
    'Token Name', // the name of the token
    '$tokenSymbol', // the symbol of the token
    "1000000000000000000000000", // the total amount of the token (with 18 decimals; 1M = 1000000000000000000000000)
    await erc20Deployer.connection.getAddress() // the owner of the total amount of the tokens (your address)
  );

console.log(tx); // { ... , contractAddress: string} 

const myToken = new ERC20(connection, tx.contractAddress);

await myToken.start() // load contract and connection into the class representing your token
await myToken.transferTokenAmount('0xYourOtherAddress', 1); // transfer 1 token from your address to other address