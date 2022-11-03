%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_le
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.math import assert_not_equal
from openzeppelin.token.erc20.IERC20 import IERC20

struct Proposal {
    amount: Uint256,
    to_: felt,
    executed: felt,
    numberOfSigners: Uint256,
    targetERC20: felt,
    timestamp: felt,
}

@storage_var
func approved_signers(proposal: Uint256, signer_nb: Uint256) -> (has_signed: felt) {
}

@storage_var
func proposals(index: Uint256) -> (proposal: Proposal) {
}

@storage_var
func signers(add: felt) -> (is_signer: felt) {
}

@storage_var
func threshold() -> (threshold: Uint256) {
}

@storage_var
func counter() -> (counter: Uint256) {
}

@view
func view_approved_signer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposal_nb: Uint256, signer_nb: Uint256
) -> (signer: felt) {
    let (res: felt) = approved_signers.read(proposal_nb, signer_nb);
    return (res,);
}

@view
func view_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposal_nb: Uint256
) -> (proposal: Proposal) {
    let (res: Proposal) = proposals.read(proposal_nb);
    return (res,);
}

@view
func view_counter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: Uint256
) {
    let (res) = counter.read();
    return (res,);
}

@event
func CreatedProposal(creator: felt, counter: Uint256) {
}

@event
func SignedProposal(signer: felt, proposal_nb: Uint256, signer_nb: Uint256) {
}

@event
func ExecutedProposal(signer: felt, amount: Uint256, to_: felt, token: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _signers_len: felt, _signers: felt*, _threshold: Uint256
) {
    fill_signers_list_from_array(_signers_len, _signers);
    threshold.write(_threshold);
    return ();
}

@external
func create_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256, to_: felt, targetERC20: felt
) -> (prop_nb: Uint256) {
    alloc_locals;
    let (caller: felt) = get_caller_address();
    let one_uint = Uint256(1, 0);
    let zero_uint = Uint256(0, 0);

    only_signer(caller);
    let (cur_counter: Uint256) = counter.read();
    let (block_timestamp: felt) = get_block_timestamp();
    let prop = Proposal(amount, to_, 0, one_uint, targetERC20, block_timestamp);
    approved_signers.write(zero_uint, zero_uint, caller);
    proposals.write(cur_counter, prop);
    let (updated_counter: Uint256) = increment_uint(cur_counter);
    counter.write(updated_counter);
    CreatedProposal.emit(caller, cur_counter);
    return (cur_counter,);
}

@external
func sign_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    proposal_nb: Uint256
) -> (success: felt) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    only_signer(caller_address);
    let zero_uint = Uint256(0, 0);
    never_signed(caller_address, proposal_nb, zero_uint);
    let (prop: Proposal) = proposals.read(proposal_nb);
    with_attr error_message("Proposal doesn't exist") {
        assert_not_equal(prop.targetERC20, 0);
    }
    approved_signers.write(proposal_nb, prop.numberOfSigners, caller_address);
    with_attr error_message("Proposal already executed") {
        assert prop.executed = 0;
    }
    let (new_number_of_signers: Uint256) = increment_uint(prop.numberOfSigners);
    let (thresh: Uint256) = threshold.read();
    let (should_be_executed: felt) = uint256_le(thresh, new_number_of_signers);
    if (should_be_executed == 1) {
        IERC20.transfer(prop.targetERC20, prop.to_, prop.amount);
        let final_prop = Proposal(
            prop.amount, prop.to_, 1, new_number_of_signers, prop.targetERC20, prop.timestamp
        );
        proposals.write(proposal_nb, final_prop);
        ExecutedProposal.emit(caller_address, prop.amount, prop.to_, prop.targetERC20);
        tempvar syscall_ptr = syscall_ptr;
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar range_check_ptr = range_check_ptr;
    } else {
        let final_prop = Proposal(
            prop.amount, prop.to_, 0, new_number_of_signers, prop.targetERC20, prop.timestamp
        );
        proposals.write(proposal_nb, final_prop);
        tempvar syscall_ptr = syscall_ptr;
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar range_check_ptr = range_check_ptr;
    }
    SignedProposal.emit(caller_address, proposal_nb, new_number_of_signers);
    return (1,);
}

func increment_uint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    val: Uint256
) -> (res: Uint256) {
    let one_as_uint = Uint256(1, 0);
    let (res: Uint256, _) = uint256_add(val, one_as_uint);
    return (res,);
}

func only_signer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    caller_address: felt
) {
    let (permission: felt) = signers.read(caller_address);
    with_attr error_message("Only signer") {
        assert permission = 1;
    }
    return ();
}

func never_signed{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    caller_address: felt, proposal_nb: Uint256, signer_index: Uint256
) {
    let (sig: felt) = approved_signers.read(proposal_nb, signer_index);
    if (sig == 0) {
        return ();
    }
    with_attr error_message("Sender has already signed") {
        assert_not_equal(sig, caller_address);
    }
    let (new_signer_index: Uint256) = increment_uint(signer_index);
    never_signed(caller_address, proposal_nb, new_signer_index);
    return ();
}

func fill_signers_list_from_array{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    signers_list_len: felt, signers_list: felt*
) -> () {
    if (signers_list_len == 0) {
        return ();
    }

    fill_signers_list_from_array(
        signers_list_len=signers_list_len - 1, signers_list=signers_list + 1
    );
    signers.write([signers_list], 1);
    return ();
}
