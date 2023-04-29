#[contract]
mod PokemonChoice {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use array::ArrayTrait;

    // Storage: data structures that are stored on the blockchain and can be accessed by the contract functions
    struct Storage {
        available_pokemon: LegacyMap::<felt252, bool>,
        pokemon_names: LegacyMap::<felt252, felt252>,
        selected_pokemon: LegacyMap::<ContractAddress, felt252>,
    }

    // Constructor: initialize the contract with available Pokemon IDs and names
    #[constructor]
    fn constructor() {
        available_pokemon::write(1, true);
        available_pokemon::write(2, true);
        available_pokemon::write(3, true);
        available_pokemon::write(4, true);

        pokemon_names::write(1, 'Pikachu');
        pokemon_names::write(2, 'Charmander');
        pokemon_names::write(3, 'Bulbasaur');
        pokemon_names::write(4, 'Squirtle');
    }

    // External functions: functions that can be called by other contracts or externally by users through a transaction on the blockchain
    #[external]
    fn choose_pokemon(pokemon_id: felt252) {
        let caller: ContractAddress = get_caller_address();
        let is_available = available_pokemon::read(pokemon_id);

        if is_available {
            selected_pokemon::write(caller, pokemon_id);
            available_pokemon::write(pokemon_id, false);
        } else {
            let mut data = ArrayTrait::new();
            data.append('POKEMON_UNAVAILABLE');
            panic(data);
        }
    }

    // Getters: view functions that return data from storage without changing it in any way (read-only)
    #[view]
    fn get_selected_pokemon(user_address: ContractAddress) -> felt252 {
        selected_pokemon::read(user_address)
    }

    // View function to get the availability of a Pokemon by ID
    #[view]
    fn is_pokemon_available(pokemon_id: felt252) -> bool {
        available_pokemon::read(pokemon_id)
    }

    // View function to get the name of a Pokemon by ID
    #[view]
    fn get_pokemon_name(pokemon_id: felt252) -> felt252 {
        pokemon_names::read(pokemon_id)
    }

    // Recursive helper function to get available Pokemons
    fn get_available_pokemons_recursive(index: felt252, max_index: felt252, available_pokemons: &ArrayTrait::<felt252>) {
        if index <= max_index {
            if available_pokemon::read(index) {
                available_pokemons.append(index);
            }
            get_available_pokemons_recursive(index + 1, max_index, available_pokemons);
        }
    }

    // View function to get the list of available Pokemons using recursion
    #[view]
    fn get_available_pokemons() -> Array::<felt252> {
        let mut available_pokemons = ArrayTrait::new();
        get_available_pokemons_recursive(1, 4, &available_pokemons);
        available_pokemons
    }
}
