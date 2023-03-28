/// Vote contract allows users to submit their votes (1 for Yes/0 for No) on a proposal.
/// It keeps track of the number of yes votes and no votes, and provides view (getter) functions
/// to check the voting status and voter eligibility.
/// The contract is initialized with a list of registered voters.
/// The contract is deployed on the StarkNet testnet. The contract address is XXX

/// Vote contract allows three registered voters to submit their votes (1 for Yes/0 for No) on a proposal.
/// It keeps track of the number of yes votes and no votes, and provides view (getter) functions 
/// to check the voting status and voter eligibility.
/// The contract is initialized with three registered voters. 
/// The contract is deployed on the StarkNet testnet. The contract address is XXX

#[contract]
mod Vote {
    // Core Library Imports
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use array::ArrayTrait;

    // ------
    // Storage: data structures that are stored on the blockchain and can be accessed by the contract functions
    // ------
    struct Storage {
        yes_votes: u8,
        no_votes: u8,
        can_vote: LegacyMap::<ContractAddress, bool>,
        registered_voter: LegacyMap::<ContractAddress, bool>,
    }

    // ------
    // Constructor: initialize the contract with the list of registered voters 
    // and set the initial vote count to 0 for both yes and no votes
    // ------

    // @dev constructor with a fixed number of registered voters (3)
    // @param voter_1 (ContractAddress): address of the first registered voter
    // @param voter_2 (ContractAddress): address of the second registered voter
    // @param voter_3 (ContractAddress): address of the third registered voter
    #[constructor]
    fn constructor(voter_1: ContractAddress, voter_2: ContractAddress, voter_3: ContractAddress) {
        // Register all voters by calling the _register_voters function 
        _register_voters(voter_1, voter_2, voter_3);

        // Initialize the vote count to 0
        yes_votes::write(0_u8);
        no_votes::write(0_u8);
    }

    // This is an alternative constructor that takes an array of addresses as input instead of a list of addresses
    // it uses recursion to register all voters

    // // @dev Initialize contract with the list of registered voters
    // // @param registered_addresses (ContractAddress*): array with the addresses of registered voters
    // #[constructor]
    // fn constructor(registered_addresses: Array::<ContractAddress>) {
    //     // Get the number of registered voters
    //     let registered_voters_len: usize = registered_addresses.len();
        
    //     // Register all voters by calling the _register_voters recursive function 
    //     // with the array of addresses and its length as index
    //     _register_voters(ref registered_addresses, registered_voters_len);

    //     // Initialize the vote count to 0
    //     yes_votes::write(0_u8);
    //     no_votes::write(0_u8);
    // }

    // ------
    // Getters: view functions that return data from storage without changing it in any way (read-only)
    // ------
    
    // @dev Return the number of yes and no votes
    // @return status (u8, u8): current status of the vote (yes votes, no votes)
    #[view]
    fn get_vote_status() -> (u8, u8) {
        // Read the number of yes votes and no votes from storage
        let n_yes = yes_votes::read();
        let n_no = no_votes::read();
        
        // Return the current voting status
        return (n_yes, n_no);
    }

    // @dev Returns if a voter can vote or not
    // @param user_address (ContractAddress): address of the voter
    // @return status (bool): true if the voter can vote, false otherwise
    #[view]
    fn voter_can_vote(user_address: ContractAddress) -> bool {
        // Read the voting status of the user from storage
        can_vote::read(user_address)
    }

    // @dev Return if an address is a voter or not (registered or not)
    // @param address (ContractAddress): address of possible voter
    // @return is_voter (bool): true if the address is a registered voter, false otherwise
    #[view]
    fn is_voter_registered(address: ContractAddress) -> bool {
        // Read the registration status of the address from storage
        registered_voter::read(address)
    }

    // ------
    // External functions: functions that can be called by other contracts or externally by users through a transaction
    // on the blockchain. They are allowed to change the state of the contract.
    // ------
    
    // @dev Submit a vote (0 for No and 1 for Yes)
    // @param vote (u8): vote value, 0 for No and 1 for Yes
    // @return () : updates the storage with the vote count and marks the voter as not allowed to vote again
    #[external]
    fn vote(vote: u8) {
        // Check if the vote is valid (0 or 1)
        assert(vote == 0_u8 | vote == 1_u8, 'VOTE_0_OR_1');

        // Know if a voter has already voted and continue if they have not voted
        let caller : ContractAddress = get_caller_address();
        assert_allowed(caller);

        // Mark that the voter has already voted and update in the storage
        can_vote::write(caller, false);

        // Update the vote count in the storage depending on the vote value (0 or 1)
        if (vote == 0_u8) {
            no_votes::write(no_votes::read() + 1_u8);
        }
        if (vote == 1_u8) {
            yes_votes::write(yes_votes::read() + 1_u8);
        }
    }

    // ------
    // Internal Functions: functions that can only be called by other functions in the same contract (private functions)
    // ------

    // @dev Assert if an address is allowed to vote or not
    // @param address (ContractAddress): address of the user
    // @return () : if the user can vote; otherwise, throw an error message and revert the transaction
    fn assert_allowed(address: ContractAddress) {
        // Read the voting status of the user from storage
        let is_voter: bool = registered_voter::read(address);
        let can_vote: bool = can_vote::read(address);

        // Check if the user can vote otherwise throw an error message and revert the transaction
        assert(is_voter == true, 'USER_NOT_REGISTERED');
        assert(can_vote == true, 'USER_ALREADY_VOTED');
    }

    // @dev Internal function to prepare the list of voters. Index can be the length of the array.
    // @param registered_addresses (Array<ContractAddress>): array with the addresses of registered voters
    // @param index (usize): index of the current voter to be processed
    fn _register_voters(
        voter_1: ContractAddress, voter_2: ContractAddress, voter_3: ContractAddress
        ) {
        // Register the first voter
        registered_voter::write(voter_1, true);
        can_vote::write(voter_1, true);

        // Register the second voter
        registered_voter::write(voter_2, true);
        can_vote::write(voter_2, true);

        // Register the third voter
        registered_voter::write(voter_3, true);
        can_vote::write(voter_3, true);
    }

    // The code below is an alternative implementation of the _register_voters function using recursion

    // // @dev Internal function to prepare the list of voters. Index can be the length of the array.
    // // @param registered_addresses (Array<ContractAddress>): array with the addresses of registered voters
    // // @param index (usize): index of the current voter to be processed
    // fn _register_voters(ref registered_addresses: Array::<ContractAddress>, index: usize) {
    //     // No more voters, recursion ends
    //     if index == 0_u32 {
    //         return();
    //     }

    //     // Get the address of the voter at the current index
    //     let voter_address: ContractAddress = *registered_addresses[index - 1_usize];

    //     // Assign the voter at address 'voter_address' a boolean value of 'true'
    //     // indicating that they are a registered voter
    //     registered_voter::write(voter_address, true);

    //     // Set the voter's 'can_vote' status to true
    //     can_vote::write(voter_address, true);

    //     // Go to the next voter using recursion, decrementing the index by 1
    //     _register_voters(registered_addresses, index - 1_usize);
    // }
}
