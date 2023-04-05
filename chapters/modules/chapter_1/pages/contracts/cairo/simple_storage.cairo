#[contract]
mod SimpleStorage {
   struct Storage {
       balance: felt252
   }

   #[event]
   fn BalanceIncreased(balance: felt252) {}

   #[external]
   fn increase_balance(amount: felt252) {
      let new_balance = balance::read() + amount;
      balance::write(new_balance);
      BalanceIncreased(new_balance);
   }

   #[view]
   fn get_balance() -> felt252 {
       balance::read()
   }
}