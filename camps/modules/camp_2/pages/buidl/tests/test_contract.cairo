%lang starknet
from starkware.cairo.common.uint256 import Uint256, uint256_eq
struct Proposal {
    amount: Uint256,
    to_: felt,
    executed: felt,
    numberOfSigners: Uint256,
    targetERC20: felt,
    timestamp: felt,
}
const SIGNER1 = 1;
const SIGNER2 = 2;
const SIGNER3 = 3;
const SIGNER4 = 4;
const SIGNER5 = 5;

@contract_interface
namespace IContract {
    func create_proposal(amount: Uint256, to_: felt, targetERC20: felt) -> (prop_nb: Uint256) {
    }

    func sign_proposal(proposal_nb: Uint256) -> (success: felt) {
    }

    func view_proposal(proposal_nb: Uint256) -> (proposal: Proposal) {
    }

    func view_approved_signer(proposal_nb: Uint256, signer_nb: Uint256) -> (signer: felt) {
    }
}

@view
func __setup__{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    local contract_address: felt;
    local mockERC20_address: felt;
    local AMOUNT: Uint256 = Uint256(100, 0);
    %{
        context.mockERC20_address = deploy_contract("./contracts/ERC20.cairo", [0, 0, 0, 100, 0, ids.SIGNER1]).contract_address
        context.contract_address = deploy_contract("./contracts/contract_final.cairo", [4, ids.SIGNER1, ids.SIGNER2, ids.SIGNER3, ids.SIGNER4, 3, 0]).contract_address
        ids.contract_address = context.contract_address
        ids.mockERC20_address = context.mockERC20_address
        stop_prank_callable = start_prank(ids.SIGNER1, ids.contract_address)
    %}
    IContract.create_proposal(
        contract_address=contract_address, amount=AMOUNT, to_=SIGNER1, targetERC20=mockERC20_address
    );
    %{ stop_prank_callable() %}
    return ();
}

@external
func test_create_proposal{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;

    local contract_address: felt;
    local mockERC20_address: felt;
    local UINT_0: Uint256 = Uint256(0, 0);
    local UINT_1: Uint256 = Uint256(1, 0);
    local AMOUNT: Uint256 = Uint256(100, 0);
    // We deploy contract and put its address into a local variable. Second argument is calldata array
    %{
        ids.contract_address = context.contract_address
        ids.mockERC20_address = context.mockERC20_address
        stop_prank_callable = start_prank(ids.SIGNER1, ids.contract_address)
        expect_events({"name": "CreatedProposal", "data": [ids.SIGNER1, 0, 0],"from_address": ids.contract_address})
    %}

    tempvar expected_proposal = Proposal(
        amount=AMOUNT,
        to_=SIGNER1,
        executed=0,
        numberOfSigners=UINT_1,
        targetERC20=mockERC20_address,
        timestamp=0,
        );

    let (actual_proposal) = IContract.view_proposal(
        contract_address=contract_address, proposal_nb=UINT_0
    );
    let (actual_signer) = IContract.view_approved_signer(
        contract_address=contract_address, proposal_nb=UINT_0, signer_nb=UINT_0
    );
    // check that the actual proposal is equal to the expected proposal
    assert expected_proposal = actual_proposal;
    assert actual_signer = SIGNER1;
    %{
        stop_prank_callable() 
        start_prank(ids.SIGNER5, ids.contract_address)
        expect_revert(error_message="Only signer")
    %}
    IContract.create_proposal(
        contract_address=contract_address, amount=AMOUNT, to_=SIGNER1, targetERC20=mockERC20_address
    );

    return ();
}

@external
func test_sign_proposal{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;

    local contract_address: felt;
    local mockERC20_address: felt;
    local UINT_0: Uint256 = Uint256(0, 0);
    local UINT_1: Uint256 = Uint256(1, 0);
    local AMOUNT: Uint256 = Uint256(100, 0);
    // We deploy contract and put its address into a local variable. Second argument is calldata array

    %{
        ids.contract_address = context.contract_address
        ids.mockERC20_address = context.mockERC20_address
        stop_prank_callable = start_prank(ids.SIGNER2, ids.contract_address)
        expect_events({"name": "SignedProposal", "data": [ids.SIGNER2, 0, 0, 2, 0],"from_address": ids.contract_address})
    %}
    let (success) = IContract.sign_proposal(contract_address=contract_address, proposal_nb=UINT_0);
    let (actual_signer) = IContract.view_approved_signer(
        contract_address=contract_address, proposal_nb=UINT_0, signer_nb=UINT_1
    );
    tempvar expected_proposal = Proposal(
        amount=AMOUNT,
        to_=SIGNER1,
        executed=0,
        numberOfSigners=Uint256(2, 0),
        targetERC20=mockERC20_address,
        timestamp=0,
        );

    let (actual_proposal) = IContract.view_proposal(
        contract_address=contract_address, proposal_nb=UINT_0
    );
    assert success = 1;
    assert actual_signer = SIGNER2;

    %{ expect_revert(error_message="Sender has already signed") %}
    IContract.sign_proposal(contract_address=contract_address, proposal_nb=UINT_0);

    return ();
}

@external
func test_sign_proposal_already_signed{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    local UINT_1: Uint256 = Uint256(1, 0);
    local contract_address: felt;
    local mockERC20_address: felt;

    %{
        ids.contract_address = context.contract_address
        ids.mockERC20_address = context.mockERC20_address
        stop_prank_callable = start_prank(ids.SIGNER1, ids.contract_address)
        expect_revert(error_message="Proposal doesn't exist")
    %}
    IContract.sign_proposal(contract_address=contract_address, proposal_nb=UINT_1);
    return ();
}

@external
func test__unknown_sign_proposal{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    local UINT_0: Uint256 = Uint256(0, 0);
    local contract_address: felt;
    local mockERC20_address: felt;

    %{
        ids.contract_address = context.contract_address
        ids.mockERC20_address = context.mockERC20_address
        stop_prank_callable = start_prank(ids.SIGNER5, ids.contract_address)
        expect_revert(error_message="Only signer")
    %}
    IContract.sign_proposal(contract_address=contract_address, proposal_nb=UINT_0);
    return ();
}

@external
func test__unknown_sign_unknown_proposal{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    local UINT_1: Uint256 = Uint256(1, 0);
    local contract_address: felt;
    local mockERC20_address: felt;

    %{
        ids.contract_address = context.contract_address
        ids.mockERC20_address = context.mockERC20_address
        stop_prank_callable = start_prank(ids.SIGNER5, ids.contract_address)
        expect_revert(error_message="Only signer")
    %}
    IContract.sign_proposal(contract_address=contract_address, proposal_nb=UINT_1);
    return ();
}
