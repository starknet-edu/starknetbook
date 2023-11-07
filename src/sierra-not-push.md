A Sierra compiled file has four key sections:

- The Sierra Program: The program that will be executed on Starknet.
- The Contract Class Version: The version of the contract class that will be used.
- The Entry Points: The functions that can be called from outside the contract.
- The ABI: The interface that can be used to call the contract from outside Starknet.

## ABI

The smart contract ABI (Application Binary Interface) is an essential component that permits various software entities to communicate effectively with one another. Analogous to a restaurant menu that describes dishes in detail, the ABI provides a comprehensive blueprint of a smart contract's functions and events. With the example ABI in hand, let's delve deeper into its specifics.

### **1. Implementation (`impl`):**

- **Name**: OwnableImpl
- **Interface Name**: starknetpy::OwnableTrait
  - This suggests that the OwnableImpl implementation derives or adheres to the "starknetpy::OwnableTrait" interface.

### **2. Interface:**

- **Name**: starknetpy::OwnableTrait
- **Items**:
  - **Function 1**:
    - **Name**: transfer_ownership
    - **Inputs**:
      - **Name**: new_owner
      - **Type**: core::starknet::contract_address::ContractAddress
      - This function allows for the contract's ownership to be transferred to another entity. As a parameter, it takes in the address of the new owner.
    - **Outputs**: None
    - **State Mutability**: external
      - This means this function can be called externally and may alter the state of the contract.
  - **Function 2**:
    - **Name**: get_owner
    - **Inputs**: None
    - **Outputs**:
      - **Type**: core::starknet::contract_address::ContractAddress
      - The function, when invoked, returns the current owner's address.
    - **State Mutability**: view
      - This means the function doesn't alter the state of the contract and is mainly used for retrieving information.

### **3. Constructor:**

- **Name**: constructor
- **Inputs**:
  - **Name**: init_owner
  - **Type**: core::starknet::contract_address::ContractAddress
  - The constructor is employed when deploying the contract. It sets the initial owner of the contract using the **`init_owner`** address parameter.

### **4. Events:**

- **Event 1**:
  - **Name**: starknetpy::OwnableContract::OwnershipTransferred1
  - **Kind**: struct
  - **Members**:
    - **Member 1**:
      - **Name**: prev_owner
      - **Type**: core::starknet::contract_address::ContractAddress
      - **Kind**: key
    - **Member 2**:
      - **Name**: new_owner
      - **Type**: core::starknet::contract_address::ContractAddress
      - **Kind**: key
  - This event records ownership changes, detailing the previous and the new owner.
- **Event 2**:
  - **Name**: starknetpy::OwnableContract::Event
  - **Kind**: enum
  - **Variants**:
    - **Variant 1**:
      - **Name**: OwnershipTransferred1
      - **Type**: starknetpy::OwnableContract::OwnershipTransferred1
      - **Kind**: nested
  - This event mirrors the "OwnershipTransferred1" event. It is presented in an enumerable form, indicating that there might be other events added to this category in the future.

From the deep dive into the ABI, it becomes evident that it is a robust descriptor of the smart contract's capabilities, outlining every function, event, and constructor in precise detail. Armed with this ABI, developers and other parties can effortlessly interface with the contract, fully comprehending its potential functionalities.

[
{
"type": "impl",
"name": "OwnableImpl",
"interface_name": "starknetpy::OwnableTrait",
},
{
"type": "interface",
"name": "starknetpy::OwnableTrait",
"items": [
{
"type": "function",
"name": "transfer_ownership",
"inputs": [
{
"name": "new_owner",
"type": "core::starknet::contract_address::ContractAddress",
}
],
"outputs": [],
"state_mutability": "external",
},
{
"type": "function",
"name": "get_owner",
"inputs": [],
"outputs": [
{"type": "core::starknet::contract_address::ContractAddress"}
],
"state_mutability": "view",
},
],
},
{
"type": "constructor",
"name": "constructor",
"inputs": [
{
"name": "init_owner",
"type": "core::starknet::contract_address::ContractAddress",
}
],
},
{
"type": "event",
"name": "starknetpy::OwnableContract::OwnershipTransferred1",
"kind": "struct",
"members": [
{
"name": "prev_owner",
"type": "core::starknet::contract_address::ContractAddress",
"kind": "key",
},
{
"name": "new_owner",
"type": "core::starknet::contract_address::ContractAddress",
"kind": "key",
},
],
},
{
"type": "event",
"name": "starknetpy::OwnableContract::Event",
"kind": "enum",
"variants": [
{
"name": "OwnershipTransferred1",
"type": "starknetpy::OwnableContract::OwnershipTransferred1",
"kind": "nested",
}
],
},
]
