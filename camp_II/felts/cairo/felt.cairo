%builtins output

from starkware.cairo.common.serialize import serialize_word

const FELT_SIZE = 2**251 + 17 * 2**192 + 1

# cairo-compile felt.cairo --output felt_compiled.json
# cairo-run --program felt_compiled.json --print_output --layout=small
func main{output_ptr : felt*}():
    # FELT_SIZE operations
    serialize_word(FELT_SIZE)
    serialize_word(FELT_SIZE - 1)
    serialize_word(FELT_SIZE + 1)

    # FELT Division
    serialize_word(6 / 3)
    serialize_word(7 / 3)

    let res = 7 / 3
    serialize_word(res * 3)

    ret
end