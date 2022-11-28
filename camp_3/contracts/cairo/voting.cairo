%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero

from openzeppelin.access.ownable.library import Ownable
from openzeppelin.security.pausable.library import Pausable

// ------
// Structs
// ------

// struct that carries the status of the vote
struct VoteCounting {
    votes_yes: felt,
    votes_no: felt,
}

// struct indicating whether a voter is allowed to vote
struct VoterInfo {
    allowed: felt,
}

// ------
// Storage
// ------

// storage variable that takes no arguments and returns the current status of the vote
@storage_var
func voting_status() -> (res: VoteCounting) {
}

// storage variable that receives an address and returns the information of that voter
@storage_var
func voter_info(user_address: felt) -> (res: VoterInfo) {
}

// storage variable that receives an address and returns if an address is registered as a voter
@storage_var
func registered_voter(address: felt) -> (is_registered: felt) {
}

// ------
// Constructor
// ------

// @dev Initialize contract
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @param admin_address (felt): admin can pause and resume the voting
// @param registered_voters_len (felt): number of registered voters
// @param registered_addresses_len (felt*): array with the addresses of registered voters
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    admin_address: felt, registered_addresses_len: felt, registered_addresses: felt*
) {
    alloc_locals;
    Ownable.initializer(admin_address);
    _register_voters(registered_addresses_len, registered_addresses);
    return ();
}

// ------
// Getters
// ------

// @dev Return address of the admin of the vote
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @return owner (felt): felt address of the admin
@view
func admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    return Ownable.owner();
}

// @dev Return if the voting is paused
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @return status (VoteCounting): 1 if paused; 0 if not
@view
func paused{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (paused: felt) {
    return Pausable.is_paused();
}

// @dev Return the voting status
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @return status (VoteCounting): current status of the vote
@view
func get_voting_status{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    status: VoteCounting
) {
    let (status) = voting_status.read();
    return (status=status);
}

// @dev Returns the status of a voter
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @return status (VoterInfo): current status of a voter
@view
func get_voter_status{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user_address: felt
) -> (status: VoterInfo) {
    let (status) = voter_info.read(user_address);
    return (status=status);
}

// @dev Return if an address is a voter
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @param address (felt): address of possible voter
// @return is_voter (felt): 1 it is a voter; 0 if is not
@view
func is_voter_registered{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (is_voter_registered: felt) {
    let (registered) = registered_voter.read(address);
    return (is_voter_registered=registered);
}

// ------
// Constant Functions: non state-changing functions
// ------

// @dev Check if the caller is allowed to vote
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @param info (VoterInfo): struct indicating whether the voter is allowed to vote
func _assert_allowed{syscall_ptr: felt*, range_check_ptr}(info: VoterInfo) {
    with_attr error_message("VoterInfo: Your address is not allowed to vote.") {
        assert_not_zero(info.allowed);
    }

    return ();
}

// ------
// Non-Constant Functions: state-changing functions
// ------

// @dev Internal function to prepare the list of voters
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @param registered_addresses_len (felt): number of registered voters
// @param registered_addresses (felt*): array with the addresses of registered voters
func _register_voters{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    registered_addresses_len: felt, registered_addresses: felt*
) {
    // No more voters, recursion ends
    if (registered_addresses_len == 0) {
        return ();
    }

    // Assign the voter at address 'registered_addresses[registered_addresses_len - 1]' a VoterInfo struct
    // indicating that they have not yet voted and can do so
    let votante_info = VoterInfo(allowed=1);
    registered_voter.write(registered_addresses[registered_addresses_len - 1], 1);
    voter_info.write(registered_addresses[registered_addresses_len - 1], votante_info);

    // Go to next voter, we use recursion
    return _register_voters(registered_addresses_len - 1, registered_addresses);
}

// @dev Given a vote, it checks if the caller can vote and updates the status of the vote, and the status of the voter
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
// @param vote (felt): vote 0 or 1
@external
func vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(vote: felt) -> () {
    alloc_locals;
    Pausable.assert_not_paused();

    // Know if a voter has already voted and continue if they have not voted
    let (caller) = get_caller_address();
    let (info) = voter_info.read(caller);
    _assert_allowed(info);

    // Mark that the voter has already voted and update in the storage
    let info_actualizada = VoterInfo(allowed=0);
    voter_info.write(caller, info_actualizada);

    // Update the vote count with the new vote
    let (status) = voting_status.read();
    local updated_voting_status: VoteCounting;
    if (vote == 0) {
        assert updated_voting_status.votes_no = status.votes_no + 1;
        assert updated_voting_status.votes_yes = status.votes_yes;
    }
    if (vote == 1) {
        assert updated_voting_status.votes_no = status.votes_no;
        assert updated_voting_status.votes_yes = status.votes_yes + 1;
    }
    voting_status.write(updated_voting_status);
    return ();
}

// @dev Pause voting for security reasons. Only the admin can pause the vote
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
@external
func pause{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Ownable.assert_only_owner();
    Pausable._pause();
    return ();
}

// @dev Resume voting. Only the admin can resume voting
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @implicit range_check_ptr
@external
func unpause{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Ownable.assert_only_owner();
    Pausable._unpause();
    return ();
}
