// ------
// Core Library Imports for the Traits outside the Starknet Contract
// ------
use starknet::ContractAddress;

// ------
// Starknet Interface: Traits that define the functions that can be implemented or called by the Starknet Contract
// ------
#[starknet::interface]
trait VoteTrait<T> {
    // ------
    // Read Functions: functions that return data from storage without changing it in any way (read-only)
    // ------
    fn get_vote_status(self: @T) -> (u8, u8, u8, u8);
    fn voter_can_vote(self: @T, user_address: ContractAddress) -> bool;
    fn is_voter_registered(self: @T, address: ContractAddress) -> bool;

    // ------
    // Write functions: functions that can be called by other contracts or externally by users through a transaction
    // on the blockchain. They are allowed to change the state of the contract.
    // ------
    fn vote(ref self: T, vote: u8);
}

/// @title Vote Contract
/// @author starknet community
/// @notice This contract allows three registered voters to submit their votes (1 for Yes/0 for No) on a proposal.
/// @dev It keeps track of the number of yes votes and no votes, and provides view (getter) functions 
/// to check the voting status and voter eligibility.
/// The contract is initialized with three registered voters. 
/// The Contract Class Hash is 0x748762322d0ee8ee30e924ba68b0633ea704fa419e86a51bc1d75be4a115ca5
/// The contract is deployed on the Starknet testnet. The contract address is 0x027f4989d3cbf1654bc95f3e0083bb4542634c7cc8c7c406f17a4335fa5860a9
#[starknet::contract]
mod Vote {
    // ------
    // Core Library Imports for the Starknet Contract
    // ------
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    // ------
    // Constants
    // ------

    /// @notice Define constants for the vote options
    const YES: u8 = 1_u8;
    const NO: u8 = 0_u8;

    /// @dev This storage structure keeps track of yes votes, no votes, 
    /// and two maps representing whether an address can vote and whether an address is a registered voter
    #[storage]
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

    /// @notice Initializes the contract with the list of registered voters 
    /// @dev Sets the initial vote count to 0 for both yes and no votes
    /// @param voter_1 The address of the first registered voter
    /// @param voter_2 The address of the second registered voter
    /// @param voter_3 The address of the third registered voter
    #[constructor]
    fn constructor(
        ref self: ContractState,
        voter_1: ContractAddress,
        voter_2: ContractAddress,
        voter_3: ContractAddress
    ) {
        // Register all voters by calling the _register_voters function 
        self._register_voters(voter_1, voter_2, voter_3);

        // Initialize the vote count to 0
        self.yes_votes.write(0_u8);
        self.no_votes.write(0_u8);
    }


    #[external(v0)]
    impl VoteImpl of super::VoteTrait<ContractState> {

        /// @notice Returns the voting results
        /// @return n_yes Number of yes votes
        /// @return n_no Number of no votes
        /// @return yes_percentage Percentage of yes votes
        /// @return no_percentage Percentage of no votes
        fn get_vote_status(self: @ContractState) -> (u8, u8, u8, u8) {
            let (n_yes, n_no) = self._get_voting_result();
            let (yes_percentage, no_percentage) = self._get_voting_result_in_percentage();
            return (n_yes, n_no, yes_percentage, no_percentage);
        }

        /// @notice Check whether a voter is allowed to vote
        /// @param user_address The address of the voter
        /// @return A boolean value representing if the voter can vote
        fn voter_can_vote(self: @ContractState, user_address: ContractAddress) -> bool {
            self.can_vote.read(user_address)
        }

        /// @notice Check whether an address is registered as a voter
        /// @param address The address to check
        /// @return A boolean value representing if the address is a registered voter
        fn is_voter_registered(self: @ContractState, address: ContractAddress) -> bool {
            self.registered_voter.read(address)
        }

        /// @notice Submit a vote
        /// @dev Updates the storage with the vote count and marks the voter as not allowed to vote again
        /// @param vote The vote value (0 for No and 1 for Yes)
        fn vote(ref self: ContractState, vote: u8) {
            assert(vote == NO || vote == YES, 'VOTE_0_OR_1');

            let caller: ContractAddress = get_caller_address();
            self._assert_allowed(caller);

            self.can_vote.write(caller, false);

            if (vote == NO) {
                self.no_votes.write(self.no_votes.read() + 1_u8);
            }
            if (vote == YES) {
                self.yes_votes.write(self.yes_votes.read() + 1_u8);
            }
        }
    }

    // ------
    // Internal Functions: functions that can only be called by other functions in the same contract (private functions)
    // There is no need to define a Trait for internal functions since we can use #[generate_trait]
    // ------

    /// @title InternalFunctions
    /// @notice Implement the InternalFunctionsTrait for the Vote contract
    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        
        // @dev Internal function to prepare the list of voters
        // @param voter_1 (ContractAddress): address of the first registered voter
        // @param voter_2 (ContractAddress): address of the second registered voter
        // @param voter_3 (ContractAddress): address of the third registered voter
        /// @notice Registers the voters and initializes their voting status to true (can vote)
        /// @param voter_1 Address of the first voter
        /// @param voter_2 Address of the second voter
        /// @param voter_3 Address of the third voter
        fn _register_voters(
            ref self: ContractState,
            voter_1: ContractAddress,
            voter_2: ContractAddress,
            voter_3: ContractAddress
        ) {
            self.registered_voter.write(voter_1, true);
            self.can_vote.write(voter_1, true);

            self.registered_voter.write(voter_2, true);
            self.can_vote.write(voter_2, true);

            self.registered_voter.write(voter_3, true);
            self.can_vote.write(voter_3, true);
        }
    }

    /// @title AssertsImpl
    /// @notice Implement the AssertsTrait for the Vote contract
    #[generate_trait]
    impl AssertsImpl of AssertsTrait {
        /// @dev A private function that checks if an address is allowed to vote
        fn _assert_allowed(self: @ContractState, address: ContractAddress) {
            let is_voter: bool = self.registered_voter.read((address));
            let can_vote: bool = self.can_vote.read((address));

            assert(is_voter == true, 'USER_NOT_REGISTERED');
            assert(can_vote == true, 'USER_ALREADY_VOTED');
        }
    }

    /// @title VotingResultImpl
    /// @notice Implement the VotingResultTrait for the Vote contract
    #[generate_trait]
    impl VoteResultFunctionsImpl of VoteResultFunctionsTrait {

        // @dev Internal function to get the voting results (yes and no vote counts)
        // @return (n_yes, n_no): number of yes votes and no votes
        /// @notice Returns the number of yes and no votes
        /// @return (n_yes, n_no): number of yes votes and number of no votes
        fn _get_voting_result(self: @ContractState) -> (u8, u8) {
            let n_yes: u8 = self.yes_votes.read();
            let n_no: u8 = self.no_votes.read();

            return (n_yes, n_no);
        }

        // @dev Internal function to calculate the voting results in percentage
        // @return (yes_percentage, no_percentage): percentage of yes votes and no votes
        /// @notice Returns the percentage of yes and no votes
        /// @return (yes_percentage, no_percentage): percentage of yes votes and no votes
        fn _get_voting_result_in_percentage(self: @ContractState) -> (u8, u8) {
            let n_yes: u8 = self.yes_votes.read();
            let n_no: u8 = self.no_votes.read();

            let total_votes: u8 = n_yes + n_no;

            let yes_percentage: u8 = (n_yes * 100_u8) / (total_votes);
            let no_percentage: u8 = (n_no * 100_u8) / (total_votes);

            return (yes_percentage, no_percentage);
        }
    }
}
