#[contract]
mod HelloStarknet {
    struct Storage {
        balance: felt252,
    }

    // Increases the balance by the given amount.
    #[external]
    fn increase_balance(amount: felt252) {
        assert(amount != 0, 'Amount cannot be 0');
        balance::write(balance::read() + amount);
    }

    // Returns the current balance.
    #[view]
    fn get_balance() -> felt252 {
        balance::read()
    }

    // Calls a function defined in outside module
    #[view]
    fn get_two() -> felt252 {
        hello_starknet::business_logic::utils::returns_two()
    }
}
