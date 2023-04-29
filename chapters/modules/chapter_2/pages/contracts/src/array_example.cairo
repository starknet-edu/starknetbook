use debug::PrintTrait; // import the PrintTrait trait
use option::OptionTrait; // import the OptionTrait trait
use box::BoxTrait;
use array::SpanTrait;
use array::ArrayTrait; // import the ArrayTrait trait


fn index_pokemon_array() {
    let mut pokemons = ArrayTrait::new();
    pokemons.append('Pikachu');
    pokemons.append('Charmander');

    let mut poke_span = pokemons.span();
    assert(poke_span.len() == 2_u32, 'Unexpected span length.');
    assert(*poke_span.get(0_u32).unwrap().unbox() == 10, 'Unexpected element');
    assert(1 == 10, 'Unexpected element');
}



fn create_pokemon_array() -> Array::<felt252> {
    let mut pokemons = ArrayTrait::new(); // create a new array of type felt252
    pokemons.append('Pikachu'); // append 'Pikachu' to the pokemons array
    pokemons.append('Charmander');
    pokemons.append('Bulbasaur');
    pokemons.append('Squirtle');
    pokemons // return the array
}

fn pop_pokemon_array() {
    let mut pokemons = ArrayTrait::new();
    pokemons.append('Pikachu');
    pokemons.append('Charmander');
    pokemons.append('Bulbasaur');
    pokemons.append('Squirtle');

    let first_pokemon = pokemons.pop_front().unwrap();
    first_pokemon.print();
}


// fn index_pokemon_array() {
//     let mut pokemons = ArrayTrait::new();
//     pokemons.append('Pikachu');
//     pokemons.append('Charmander');

//     let first_pokemon = pokemons.get(0_usize).unwrap();
//     let second_pokemon = pokemons.at(1_usize);

//     assert(*first_pokemon == 'Pikachu', 'first_pokemon should be Pikachu');
// }

