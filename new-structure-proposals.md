
### New structure proposal

0. [Primer](./primer/) - Ben & Henri
   1. Bitcoin
   2. Smart Contracts
   3. Ethereum
   4. Signing Contracts in Bitcoin and StarkNet
   5. Rollups
   6. A Primer on ZKEVMs and Alternative VMs
   7. Elliptic curve cryptography
   8. Hashing

1. [Camp 1: Getting Started](./camp_1/) - Omar
Camp's goal: the student will be able to code, deploy and interact with **quality** smart contracts that leverage the low-fees provided by StarkNet. They will get a proficient level in Cairo.
   1. Setting up your environment
   2. Cairo: Basics
      1. Types
      2. Pointers
      3. Struct
   3. StarkNet contracts basics
      1. Storage vars
      2. Functions
   4. Basics of the starknet CLI
      1. Create an account contract
      2. Declare a class hash
      3. Deploying a smart contract
      4. Invoke a deployed smart contract
   5. StarkNet contracts intermediate
      1. Calling other contracts
      2. L1/L2 interactions
      3. StarkNet's UDC
   6. Industry standards
      1. Open Zeppelin
      2. Deploying an ERC20
      3. Deploying an ERC721
      4. Deploying an ERC1155
      5. Deploying a proxy
   7.  Cairo: Best practices
      1. SOLID Cairo: OOP-like programming, and iterator pattern
      2. Recursion
      3. Importing libraries
   7.  Cairo on StarkNet: Interactive tutorials
      1. Cairo 101
      2. starknet-erc20 
      3. starknet-erc721
      4. starknet-messaging-bridge
      5. starknet-debug
Observations:
* Omar: 
  * The "Customizing an account contract" could be a bit too advanced for the Getting Started camp. I think it  could better go in Camp 3.
  * The "Writing a dapp", "Building a front end" and "Libraries" parts could go in Camp 2 where we teach tooling.
  * The "What is an ERC20? (starknet-erc20)" and "What is an ERC721? (starknet-erc721)" could already go inside the "Deploying an ERC20" and "Deploying an ERC721" sections.


2. [Camp 2: BUIDL and Tooling](./camp_2/) - Seabook & Henri
   1. Tools:
   2. Devnet
   3. Protostar
   4. Nile
   5. Hardhat
   6. Third party libraries
   7. `starknet_py` 
   8. `starknet.js`
   9. Caigo
   10. Open Zeppelin
   11. Running a node
   12. Indexing starknet
   13. Best practices
   14. Testing
   15. Libraries

3. [Camp 3: StarkNet](./camp_3/) - David
   1. Blocks
   2. The Lifecycle of Transactions
   3. StarkNet OS
   4. StarkNet CLI
   5. State Transition/Fees
   6. Account Contracts
   7. Account Abstraction
   8. L1-L2 Messaging
   9. The `starkware` Python library
   10. Sequencers
   11. Provers
   12. Verifiers on Solidity
   13. Verifiers in Cairo
   14. Hints
   15. Fee calculation and paying for fees

4. [Camp 4: Peering into the future](./camp_4/) - David
   1. Data Availability
   2. Recursion / Fractal scaling
   3. Throughput
   4. Decentralization
   5. Building Community
   6. Fee market
   7. 

5. [Camp 5: Cairo](./camp_5/) - Ben
   1. C(pu)AIR(o)
   2. Computational Integrity
   3. Syntax
   4. Cairo VM

6. [Camp 6: STARKs](./camp_6/) - Omar & Henri
   Camp's goal: the student will be able to understand the foundamental underpinnings of what is an STARKs and how it works. It is **not the goal** to make the student proficient in cryptography but to allow they to understand technical texts on ZK cryptography. 
   1. Trust vs. Verification (introduction to the problem STARKs aim to solve)
      1. The Computational Integrity (CI) problem
      2. “Old World”: Trust, or Delegated Accountability
      3. Proof systems
   2. First Look at the STARKs (non mathematical introduction to what a STARK is)
      1. Scalability: Exponential Speedup of Verification
      2. Transparency: With Trust Toward None, with Integrity for All
      3. Lean Cryptography: Secure & Fast
   3. Mathematic primer
      1. Algebraic Number Theory:
         1. Prime numbers 
         2. Quadratic residues 
         3. Euler's theorem 
         4. Finite fields 
         5. Modular arithmetic 
         6. Congruences
      2. Algebraic Geometry: 
         1. Polynomials 
         2. Points, lines, and curves
         3. Algebraic varieties 
         4. Divisors 
         5. Algebraic morphisms 
         6. Sheaves 
      3. Cryptography: 
         1. Cryptographic hash functions 
         2. Asymmetric encryption 
         3. Digital signatures 
         4. Zero-knowledge proofs 
         5. Commitment schemes 
         6. Secure Multi-Party Computation (MPC)
      4. Modular Arithmetic
      5. Finite Field Arithmetic
      6. Polynomial Arithmetic
   6. Arithmetization
      1. Step 1: Generating an execution trace and a set of polynomial constraints
      2. Step 2: Transform the execution trace and the set of polynomial constraints into a single low-degree polynomial
      3. Succinctness
   7. Low Degree Testing: The Secret Sauce of Succinctness
      1. The Direct Test
      2. Direct Test does not suffice: Prover to the rescue
   8. The FRI Protocol
   9. Efficient STARKs
       1.  Micali construction
       2.  Interactive Oracle Proofs (IOPs)
       3.  BCS construction
   10. STARKs and SNARKs: differences

Observations:
* Omar: 
  * The structure of this content is mainly based in the 5-part [STARK Math series](https://medium.com/starkware/a-framework-for-efficient-starks-19608ba06fbe) by Starkware (2019). Some topics and format were moved for didactic purposes. 
  * Additional content was added on Modular, Finite Field and Polynomial arithmetic. Also, on the differences with SNARKs.


7. Lost & found
   Add items that were in your category, but you don't want in.
   1. "Customizing an account contract" could go in Camp 3.
   2. "Writing a dapp", "Building a front end" and "Libraries" parts could go in Camp 2 where we teach tooling.

