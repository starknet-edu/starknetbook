#[contract]
mod BigPokemon {
    use option::OptionTrait; // import the OptionTrait trait
    use box::BoxTrait;
    use array::SpanTrait;
    use array::ArrayTrait; // import the ArrayTrait trait

    struct Pokemon {
        name: felt252,
        id: felt252
    }

    #[constructor]
    fn constructor() { // let pokemons : Array<felt252> = create_pokemon_array();
    }

    fn create_pokemon_array() -> Array::<Pokemon> {
        let mut pokemons: Array<Pokemon> = ArrayTrait::new(); // create a new array of type felt252
        pokemons
            .append(Pokemon { name: 'Pikachu', id: 1 }); // append 'Pikachu' to the pokemons array
        pokemons.append(Pokemon { name: 'Charmander', id: 2 });
        pokemons.append(Pokemon { name: 'Bulbasaur', id: 3 });
        pokemons.append(Pokemon { name: 'Squirtle', id: 4 });
        pokemons // return the array
    }


    // fn create_pokemon_array() -> Array::<felt252> {
    //     let mut pokemons = ArrayTrait::new(); // create a new array of type felt252
    //     pokemons.append('Pikachu'); // append 'Pikachu' to the pokemons array
    //     pokemons.append('Charmander');
    //     pokemons.append('Bulbasaur');
    //     pokemons.append('Squirtle');
    //     pokemons // return the array
    // }

    fn pop_pokemon_array() {
        let mut pokemons: Array<felt252> = create_pokemon_array();
        assert(pokemons.len() == 4_usize, 'Unexpected length.');
        let first_pokemon = pokemons.pop_front().unwrap();
        assert(pokemons.len() == 3_usize, 'Unexpected length.');
        assert(first_pokemon == 'Pikachu', 'Unexpected pokemon.');
    }

    fn index_pokemon_array() {
        let mut pokemons: Array<felt252> = create_pokemon_array();

        assert(*pokemons.get(0_usize).unwrap().unbox() == 'Pikachu', 'Wrong pokemon');
        assert(*pokemons.at(1_usize) == '342432', 'Wrong pokemon');
    }

    fn index_pokemon_span() {
        let mut pokemons_span: Span<felt252> = create_pokemon_array().span();

        assert(*pokemons_span.get(2_usize).unwrap().unbox() == 'Bulbasaur', 'Wrong pokemon');
        assert(*pokemons_span.at(3_usize) == 'Squirtle', 'Wrong pokemon');
    }

    #[view]
    fn test_pop_pokemon_array() -> felt252 {
        pop_pokemon_array();
        1
    }
    #[view]
    fn test_index_pokemon_array() -> felt252 {
        index_pokemon_array();
        1
    }
    #[view]
    fn test_index_pokemon_span() -> felt252 {
        index_pokemon_span();
        1
    }
}
