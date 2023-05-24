#[test]
fn test_returns_two() {
    assert(hello_starknet::business_logic::utils::returns_two() == 2, 'Should return 2');
}
