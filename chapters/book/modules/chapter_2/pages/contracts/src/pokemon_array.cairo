/// @title PokeArray
/// @dev This is a Starknet smart contract written in Cairo that demonstrates basic operations with Array and Span. It is used to manage a collection of pokemons.

#[starknet::interface]
/// @title PokemonTrait
/// @dev This is an interface that encapsulates operations related to managing an Array and Span in a Starknet Smart Contract. This is specifically for managing pokemons.
trait PokemonTrait<T> {
    /// @dev This is a function to simulate the operation of removing a pokemon from the array.
    fn test_pop_pokemon_array(self: @T) -> felt252;

    /// @dev This is a function to simulate the operation of indexing a pokemon from the array.
    fn test_index_pokemon_array(self: @T) -> felt252;

    /// @dev This is a function to simulate the operation of indexing a pokemon from a span.
    fn test_index_pokemon_span(self: @T) -> felt252;
}

#[starknet::contract]
mod PokeArray {
    use option::OptionTrait;
    use box::BoxTrait;
    use array::SpanTrait;
    use array::ArrayTrait;

    #[storage]
    struct Storage {}

    /// @dev Constructor for initializing the PokeArray contract.
    #[constructor]
    fn constructor(ref self: ContractState) {}

    /// @dev Implementation of the PokemonTrait.
    #[external(v0)]
    impl PokemonImpl of super::PokemonTrait<ContractState> {
        /// @dev A function that runs a simulation for removing a pokemon from the array.
        fn test_pop_pokemon_array(self: @ContractState) -> felt252 {
            self._pop_pokemon_array();
            1
        }

        /// @dev A function that runs a simulation for indexing a pokemon from the array.
        fn test_index_pokemon_array(self: @ContractState) -> felt252 {
            self._index_pokemon_array();
            1
        }

        /// @dev A function that runs a simulation for indexing a pokemon from a span.
        fn test_index_pokemon_span(self: @ContractState) -> felt252 {
            self._index_pokemon_span();
            1
        }
    }

    /// @dev This is a set of internal helper functions used by the main functions defined in PokemonTrait.
    #[generate_trait]
    impl PokeFunctionsImpl of PokeFunctionsTrait {
        /// @dev A function to create an array of pokemons.
        fn _create_pokemon_array(self: @ContractState) -> Array::<felt252> {
            let mut pokemons = ArrayTrait::new();
            pokemons.append('Pikachu');
            pokemons.append('Charmander');
            pokemons.append('Bulbasaur');
            pokemons.append('Squirtle');
            pokemons
        }

        /// @dev A function to remove the first element from the pokemon array.
        fn _pop_pokemon_array(self: @ContractState) {
            let mut pokemons: Array<felt252> = self._create_pokemon_array();
            assert(pokemons.len() == 4_usize, 'Unexpected length.');
            let first_pokemon = pokemons.pop_front().unwrap();
            assert(pokemons.len() == 3_usize, 'Unexpected length.');
            assert(first_pokemon == 'Pikachu', 'Unexpected pokemon.');
        }

        /// @dev A function to index the pokemon array to check the values.
        fn _index_pokemon_array(self: @ContractState) {
            let mut pokemons: Array<felt252> = self._create_pokemon_array();
            assert(*pokemons.get(0_usize).unwrap().unbox() == 'Pikachu', 'Wrong pokemon');
            assert(*pokemons.at(1_usize) == 'Charmander', 'Wrong pokemon');
        }

        /// @dev A function to index the pokemon span to check the values.
        fn _index_pokemon_span(self: @ContractState) {
            let mut pokemons_span: Span<felt252> = self._create_pokemon_array().span();
            assert(*pokemons_span.get(2_usize).unwrap().unbox() == 'Bulbasaur', 'Wrong pokemon');
            assert(*pokemons_span.at(3_usize) == 'Squirtle', 'Wrong pokemon');
        }
    }
}
