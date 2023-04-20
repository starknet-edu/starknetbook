/// @title Vote Contract
/// @author starknet community
/// @notice This contract allows three registered voters to submit their votes (1 for Yes/0 for No) on a proposal.
/// @dev It keeps track of the number of yes votes and no votes, and provides view (getter) functions 
/// to check the voting status and voter eligibility.
/// The contract is initialized with three registered voters. 
/// The contract is deployed on the StarkNet testnet. The contract address is 0x0780b126f03c2e28a3ecd27e6c1c367d3df796050f0831e36c899a8c2f1dbdbb

#[contract]
mod Vote2 {
    // Core Library Imports
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use array::ArrayTrait;

    // ------
    // Traits
    // ------

    /// @title VotingResultTrait
    /// @notice A trait for retrieving the results of the voting
    trait VotingResultTrait {
        fn get_voting_result() -> (u8, u8);
        fn get_voting_result_in_percentage() -> (u8, u8);
    }

    /// @title VotingResultImpl
    /// @notice Implement the VotingResultTrait for the Vote contract
    impl VotingResultImpl of VotingResultTrait {
        #[inline(always)]
        fn get_voting_result() -> (u8, u8) {
            // Read the number of yes votes and no votes from storage
            let n_yes: u8 = yes_votes::read();
            let n_no: u8 = no_votes::read();

            // Return the current voting status
            return (n_yes, n_no);
        }
        #[inline(always)]
        fn get_voting_result_in_percentage() -> (u8, u8) {
            // Read the number of yes votes and no votes from storage
            let n_yes: u8 = yes_votes::read();
            let n_no: u8 = no_votes::read();

            // Calculate the total votes
            let total_votes: u8 = n_yes + n_no;

            // Calculate the percentage of yes and no votes
            let yes_percentage: u8 = (n_yes * 100_u8) / (total_votes) ;
            let no_percentage: u8 = (n_no * 100_u8) / (total_votes) ;

            // Return the voting results in percentage
            return (yes_percentage, no_percentage);
        }
    }

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
    // Constants
    // ------

    /// @notice Define constants for the vote options
    const YES: u8 = 1_u8;
    const NO: u8 = 0_u8;

    // ------
    // Events
    // ------

    /// @notice Event emitted when a vote is cast
    /// @param voter (ContractAddress): The address of the voter
    /// @param vote (u8): The vote value (0 for No, 1 for Yes)
    #[event]
    fn VoteCast(voter: ContractAddress, vote: u8) {}

    // ------
    // Constructor: initialize the contract with the list of registered voters 
    // and set the initial vote count to 0 for both yes and
    // no votes
    // ------

    /// @notice Constructor with a fixed number of registered voters (3)
    /// @param voter_1 (ContractAddress): address of the first registered voter
    /// @param voter_2 (ContractAddress): address of the second registered voter
    /// @param voter_3 (ContractAddress): address of the third registered voter
    #[constructor]
    fn constructor(voter_1: ContractAddress, voter_2: ContractAddress, voter_3: ContractAddress) {
        // Register all voters by calling the _register_voters function 
        _register_voters(voter_1, voter_2, voter_3);

        // Initialize the vote count to 0
        yes_votes::write(0_u8);
        no_votes::write(0_u8);
    }

    // ------
    // Getters: view functions that return data from storage without changing it in any way (read-only)
    // ------

    /// @notice Returns the voting results
    /// @return (n_yes, n_no, yes_percentage, no_percentage): number of yes votes, number of no votes,
    ///         percentage of yes votes, and percentage of no votes
    #[view]
    fn get_vote_results() -> (u8, u8, u8, u8) {
        let (n_yes, n_no) = VotingResultTrait::get_voting_result();
        let (yes_percentage, no_percentage) = VotingResultTrait::get_voting_result_in_percentage();
        return (n_yes, n_no, yes_percentage, no_percentage);
    }

    /// @notice Returns if a voter can vote or not
    /// @param user_address (ContractAddress): address of the voter
    /// @return status (bool): true if the voter can vote, false otherwise
    #[view]
    fn voter_can_vote(user_address: ContractAddress) -> bool {
        // Read the voting status of the user from storage
        can_vote::read(user_address)
    }

    /// @notice Return if an address is a voter or not (registered or not)
    /// @param address (ContractAddress): address of possible voter
    /// @return is_voter (bool): true if the address is a registered voter, false otherwise
    #[view]
    fn is_voter_registered(address: ContractAddress) -> bool {
        // Read the registration status of the address from storage
        registered_voter::read(address)
    }

    // ------
    // External functions: functions that can be called by other contracts or externally by users through a transaction
    // on the blockchain. They are allowed to change the state of the contract.
    // ------

    /// @notice Submit a vote (0 for No and 1 for Yes)
    /// @param vote (u8): vote value, 0 for No and 1 for Yes
    /// @return (): updates the storage with the vote count and marks the voter as not allowed to vote again
    #[external]
    fn vote(vote: u8) {
        // Check if the vote is valid (0 or 1)
        assert(vote == NO | vote == YES, 'VOTE_0_OR_1');

        // Know if a voter has already voted and continue if they have not voted
        let caller: ContractAddress = get_caller_address();
        assert_allowed(caller);

        // Mark that the voter has already voted and update in the storage
        can_vote::write(caller, false);

        // Update the vote count in the storage depending on the vote value (0 or 1)
        if (vote == NO) {
            no_votes::write(no_votes::read() + 1_u8);
        }
        if (vote == YES) {
            yes_votes::write(yes_votes::read() + 1_u8);
        }

        // Emit the VoteCast event after the vote has been processed
        VoteCast(caller, vote);
    }

    // ------
    // Internal Functions: functions that can only be called by other functions in the same contract (private functions)
    // ------

    /// @notice Assert if an address is allowed to vote or not
    /// @param address (ContractAddress): address of the user
    /// @return (): if the user can vote; otherwise, throw an error message and revert the transaction
    fn assert_allowed(address: ContractAddress) {
        // Read the voting status of the user from storage
        let is_voter: bool = registered_voter::read(address);
        let can_vote: bool = can_vote::read(address);

        // Check if the user can vote otherwise throw an error message and revert the transaction
        assert(is_voter == true, 'USER_NOT_REGISTERED');
        assert(can_vote == true, 'USER_ALREADY_VOTED');
    }

    /// @notice Internal function to prepare the list of voters.
    /// @param voter_1 (ContractAddress): address of the first registered voter
    /// @param voter_2 (ContractAddress): address of the second registered voter
    /// @param voter_3 (ContractAddress): address of the third registered voter
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
}

