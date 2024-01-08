use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait, start_prank, CheatTarget};
use voting::{IVotingContractDispatcher, IVotingContractSafeDispatcher};
use voting::{IVotingContractDispatcherTrait, IVotingContractSafeDispatcherTrait};

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@array![]).unwrap()
}

fn expect_votes_counters_values(
    contract_address: ContractAddress, expected_no_votes: felt252, expected_yes_votes: felt252
) {
    let dispatcher = IVotingContractDispatcher { contract_address };
    let (no_votes, yes_votes) = dispatcher.get_votes();
    assert(no_votes == expected_no_votes, 'no votes value incorrect');
    assert(yes_votes == expected_yes_votes, 'yes votes value incorrect');
}

fn vote_with_caller_address(
    contract_address: ContractAddress, pranked_address: felt252, value: felt252
) {
    start_prank(CheatTarget::One(contract_address), pranked_address.try_into().unwrap());
    let dispatcher = IVotingContractDispatcher { contract_address };
    dispatcher.vote(value);
}

#[test]
fn test_votes_counter_change() {
    let contract_address = deploy_contract('VotingContract');

    expect_votes_counters_values(contract_address, 0, 0);

    let dispatcher = IVotingContractDispatcher { contract_address };
    dispatcher.vote(1);

    expect_votes_counters_values(contract_address, 0, 1);
}

#[test]
fn test_voting_multiple_times_from_different_accounts() {
    let contract_address = deploy_contract('VotingContract');

    expect_votes_counters_values(contract_address, 0, 0);

    vote_with_caller_address(contract_address, 101, 1);
    vote_with_caller_address(contract_address, 102, 1);
    vote_with_caller_address(contract_address, 103, 0);
    vote_with_caller_address(contract_address, 104, 0);
    vote_with_caller_address(contract_address, 105, 0);

    expect_votes_counters_values(contract_address, 3, 2);
}

#[test]
fn test_voting_twice_from_the_same_account() {
    let contract_address = deploy_contract('VotingContract');

    start_prank(CheatTarget::One(contract_address), 123.try_into().unwrap());

    let safe_dispatcher = IVotingContractSafeDispatcher { contract_address };

    safe_dispatcher.vote(1).unwrap();

    match safe_dispatcher.vote(0) {
        Result::Ok(_) => panic(array!['shouldve panicked']),
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'you have already voted', *panic_data.at(0));
        }
    }
}
