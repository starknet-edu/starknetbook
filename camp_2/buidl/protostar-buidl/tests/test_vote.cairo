%lang starknet

from src.interfaces.IVote import IVote

// ---------
// CONSTANTS
// ---------

const ADMIN = 1010;
const NUMBER_VOTERS = 3;
const VOTER_1 = 111;
const VOTER_2 = 222;
const VOTER_3 = 333;


// ---------
// TESTS
// ---------

// Deploy at the beginning of the test suite so you do not have to redeploy for each test
@external
func __setup__() {
    %{ 
        declared = declare("src/voting.cairo")
        prepared = prepare(declared, [ids.ADMIN, ids.NUMBER_VOTERS, ids.VOTER_1, ids.VOTER_2, ids.VOTER_3])
        context.context_vote_address = deploy(prepared).contract_address
    %}
    return ();
}

@external
func test_vote_contract_deploy{syscall_ptr: felt*, range_check_ptr}() {

    tempvar vote_address: felt;

    %{  
        ids.vote_address = context.context_vote_address
    %}

    // Test the admin view function
    let (admin) = IVote.admin(contract_address=vote_address);
    assert ADMIN = admin;
    
    // Test the is_voter_registered view function; where the voters registered?
    let (voter_1) = IVote.is_voter_registered(contract_address=vote_address, address=VOTER_1);
    assert 1 = voter_1;
    let (voter_2) = IVote.is_voter_registered(contract_address=vote_address, address=VOTER_2);
    assert 1 = voter_2;
    let (voter_3) = IVote.is_voter_registered(contract_address=vote_address, address=VOTER_3);
    assert 1 = voter_2;

    %{  
        print("🐺 Successful deployment of the contract; constructor successfully implemented")
    %}

    return ();
}


@external
func test_vote_contract_initial_status{syscall_ptr: felt*, range_check_ptr}() {

    tempvar vote_address: felt;

    %{  
        ids.vote_address = context.context_vote_address
    %}

    // Test the get_voter_status view function; can the registered voters vote?
    let (voter_1_status) = IVote.get_voter_status(contract_address=vote_address, user_address=VOTER_1);
    let voter_1_allowed = voter_1_status.allowed;
    assert 1 = voter_1_allowed;
    let (voter_2_status) = IVote.get_voter_status(contract_address=vote_address, user_address=VOTER_2);
    let voter_2_allowed = voter_2_status.allowed;
    assert 1 = voter_2_allowed;
    let (voter_3_status) = IVote.get_voter_status(contract_address=vote_address, user_address=VOTER_3);
    let voter_3_allowed = voter_3_status.allowed;
    assert 1 = voter_3_allowed;

    // Test the get_voting_status view function; can the registered voters vote?
    let (vote_status) = IVote.get_voting_status(contract_address=vote_address);
    let votes_yes = vote_status.votes_yes;
    assert 0 = votes_yes;
    let votes_no = vote_status.votes_no;
    assert 0 = votes_no;

    %{  
        print("🐺 Successful initial status of the vote 🐺")
    %}

    return ();
}

@external
func test_vote_contract_pause_vote{syscall_ptr: felt*, range_check_ptr}() {

    tempvar vote_address: felt;

    %{  
        ids.vote_address = context.context_vote_address
    %}

    // Test the paused view function; was the vote paused? No
    let (paused) = IVote.paused(contract_address=vote_address);
    assert 0 = paused;

    // Pause the voting contract; we invoke it as if we were the ADMIN
    %{ stop_prank_admin = start_prank(ids.ADMIN, ids.vote_address) %}
    IVote.pause(contract_address=vote_address);
    %{ stop_prank_admin() %}

    // Test the pause external function; was the vote paused? Yes
    let (paused) = IVote.paused(contract_address=vote_address);
    assert 1 = paused;

    // Unpause the voting contract and test it
    %{ stop_prank_admin = start_prank(ids.ADMIN, ids.vote_address) %}
    IVote.unpause(contract_address=vote_address);
    %{ stop_prank_admin() %}
    let (paused) = IVote.paused(contract_address=vote_address);
    assert 0 = paused;

    %{  
        print("🐺 Successful pause and unpause of voting")
    %}

    return ();
}


@external
func test_vote_contract_vote{syscall_ptr: felt*, range_check_ptr}() {

    tempvar vote_address: felt;

    %{  
        ids.vote_address = context.context_vote_address
    %}

    // VOTER_1 votes NO (0)
    %{ stop_prank_voter = start_prank(ids.VOTER_1, ids.vote_address) %}
    IVote.vote(contract_address=vote_address, vote=0);
    %{ stop_prank_voter() %}

    // Test the get_voting_status after VOTER_1 vote; do we have 1 vote in votes_no? YES
    let (vote_status) = IVote.get_voting_status(contract_address=vote_address);
    let votes_yes = vote_status.votes_yes;
    assert 0 = votes_yes;
    let votes_no = vote_status.votes_no;
    assert 1 = votes_no;

    // Test the voter status of VOTER_1 after voting; can VOTER_1 still vote? NO
    let (voter_1_status) = IVote.get_voter_status(contract_address=vote_address, user_address=VOTER_1);
    let voter_1_allowed = voter_1_status.allowed;
    assert 0 = voter_1_allowed;

    // Make VOTER_1 try to vote again; an error should appear
    %{ expect_revert(error_message="not allowed to vote") %}
    %{ stop_prank_voter = start_prank(ids.VOTER_1, ids.vote_address) %}
    IVote.vote(contract_address=vote_address, vote=0);
    %{ stop_prank_voter() %}

    // Repeat process with VOTER_2
    %{ stop_prank_voter = start_prank(ids.VOTER_2, ids.vote_address) %}
    IVote.vote(contract_address=vote_address, vote=1);
    %{ stop_prank_voter() %}
    let (vote_status) = IVote.get_voting_status(contract_address=vote_address);
    let votes_yes = vote_status.votes_yes;
    assert 1 = votes_yes;
    let votes_no = vote_status.votes_no;
    assert 1 = votes_no;
    let (voter_2_status) = IVote.get_voter_status(contract_address=vote_address, user_address=VOTER_1);
    let voter_2_allowed = voter_2_status.allowed;
    assert 0 = voter_2_allowed;
    %{ expect_revert(error_message="not allowed to vote") %}
    %{ stop_prank_voter = start_prank(ids.VOTER_2, ids.vote_address) %}
    IVote.vote(contract_address=vote_address, vote=0);
    %{ stop_prank_voter() %}

    %{  
        print("🐺 Successful vote")
    %}

    return ();
}
