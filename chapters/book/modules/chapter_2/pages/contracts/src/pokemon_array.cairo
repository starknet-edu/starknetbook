/// @title PokeArray
/// @notice A Starknet smart contract that demonstrates basic operations with Array and Span in Cairo.
/// @author Your Name
#[contract]
mod PokeArray {
    use option::OptionTrait;
    use box::BoxTrait;
    use array::SpanTrait;
    use array::ArrayTrait;

    /// @notice Constructor for the PokeArray contract.
    #[constructor]
    fn constructor() {}

    /// @notice Creates an array of pokemons.
    /// @return Array of felt252 representing pokemons.
    fn create_pokemon_array() -> Array::<felt252> {
        let mut pokemons = ArrayTrait::new();
        pokemons.append('Pikachu');
        pokemons.append('Charmander');
        pokemons.append('Bulbasaur');
        pokemons.append('Squirtle');
        pokemons
    }

    /// @notice Removes the first element of the pokemons array.
    fn pop_pokemon_array() {
        let mut pokemons: Array<felt252> = create_pokemon_array();
        assert(pokemons.len() == 4_usize, 'Unexpected length.');
        let first_pokemon = pokemons.pop_front().unwrap();
        assert(pokemons.len() == 3_usize, 'Unexpected length.');
        assert(first_pokemon == 'Pikachu', 'Unexpected pokemon.');
    }

    /// @notice Indexes the pokemon array to ensure the values are correct.
    fn index_pokemon_array() {
        let mut pokemons: Array<felt252> = create_pokemon_array();

        assert(*pokemons.get(0_usize).unwrap().unbox() == 'Pikachu', 'Wrong pokemon');
        assert(*pokemons.at(1_usize) == 'Charmander', 'Wrong pokemon');
    }

    /// @notice Indexes the pokemon span to ensure the values are correct.
    fn index_pokemon_span() {
        let mut pokemons_span: Span<felt252> = create_pokemon_array().span();

        assert(*pokemons_span.get(2_usize).unwrap().unbox() == 'Bulbasaur', 'Wrong pokemon');
        assert(*pokemons_span.at(3_usize) == 'Squirtle', 'Wrong pokemon');
    }

    /// @notice A view function to test the pop_pokemon_array function.
    /// @return A constant value 1 to indicate the function has been executed.
    #[view]
    fn test_pop_pokemon_array() -> felt252 {
        pop_pokemon_array();
        1
    }

    /// @notice A view function to test the index_pokemon_array function.
    /// @return A constant value 1 to indicate the function has been executed.
    #[view]
    fn test_index_pokemon_array() -> felt252 {
        index_pokemon_array();
        1
    }

    /// @notice A view function to test the index_pokemon_span function.
    /// @return A constant value 1 to indicate the function has been executed.
    #[view]
    fn test_index_pokemon_span() -> felt252 {
        index_pokemon_span();
        1
    }
}
