# Important Starknet Methods

The table below contains important methods used while building starknet smart contracts. It contains the name of the method, a keyword to import such a method, and finally a simple single line usage of each method. Also note that multiple method imports can be chained to make the codebase simpler and also avoid repetition, e.g., `use starknet::{get_contract_address, ContractAddress}.

### Table 1.0

<table>
  <tr>
   <td><strong>METHODS</strong>
   </td>
   <td><strong>IMPORTATION</strong>
   </td>
   <td><strong>EXAMPLE USAGE</strong>
   </td>
   <td><strong> DESCRIPTION </strong>
   </td>
  </tr>
  <tr>
   <td>get_contract_address()
   </td>
   <td>use starknet::get_contract_address
   </td>
   <td>let ThisContract = get_contract_address();
   </td>
   <td>Returns the contract address of the contract containing this method.
   </td>
  </tr>
  <tr>
   <td>get_caller_address()
   </td>
   <td>use starknet::get_caller_address
   </td>
   <td>let user = get_caller_address();
   </td>
   <td>Returns the contract address of the user calling a certain function.
   </td>
  </tr>
  <tr>
   <td>ContractAddress
   </td>
   <td>use starknet::ContractAddress
   </td>
   <td>let user: ContractAddress = get_caller_address();
   </td>
   <td>Allows for the usage of the contract address data type in a contract.
   </td>
  </tr>
  <tr>
   <td>zero()
   </td>
   <td>use starknet::ContractAddress
   </td>
   <td>let addressZero: ContractAddress  = zero();
   </td>
   <td>Returns address zero contract address
   </td>
  </tr>
  <tr>
   <td>get_block_info()
   </td>
   <td>use starknet::get_block_info
   </td>
   <td>let blockInfo = get_block_info();
   </td>
   <td>It returns a struct containing the block number, block timestamp, and the sequencer address. 
   </td>
  </tr>
  <tr>
   <td>get_tx_info()
   </td>
   <td>use starknet::get_tx_info
   </td>
   <td>let txInfo = get_tx_info();
   </td>
   <td>Returns a struct containing transaction version, max fee, transaction hash, signature, chain ID, nonce, and transaction origin address.
   </td>
  </tr>
  <tr>
   <td>get_block_timestamp()
   </td>
   <td>use starknet::get_block_timestamp
   </td>
   <td>let timeStamp = get_block_timestamp();
   </td>
   <td>Returns the block timestamp of the block containing the transaction.
   </td>
  </tr>
  <tr>
   <td>get_block_number()
   </td>
   <td>use starknet::get_block_number
   </td>
   <td>Let blockNumber = get_block_number();
   </td>
   <td>Returns the block number of the block containing the transaction.
   </td>
  </tr>
  <tr>
   <td>ClassHash
   </td>
   <td>use starknet::ClassHash
   </td>
   <td>let childHash: ClassHash = contractClassHash;
   </td>
   <td>Allows for the use of the class Hash datatype to define variables that hold a class hash.
   </td>
  </tr>
</table>
