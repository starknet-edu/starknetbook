%lang starknet

struct VoteCounting {
    votes_yes: felt,
    votes_no: felt,
}

struct VoterInfo {
    allowed: felt,
}

@contract_interface
namespace IVote {
    func admin() -> (owner: felt) {
    }

    func paused() -> (paused: felt) {
    }

    func get_voting_status() -> (status: VoteCounting) {
    }

    func get_voter_status(user_address: felt) -> (status: VoterInfo) {
    }

    func is_voter_registered(address: felt) -> (is_voter_registered: felt) {
    }

    func vote(vote: felt) -> () {
    }

    func pause() -> () {
    }

    func unpause() -> () {
    }
}
