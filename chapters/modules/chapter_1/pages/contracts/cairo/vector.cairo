%builtins output

from starkware.cairo.common.serialize import serialize_word

struct Vector2d {
    x: felt,
    y: felt,
}

func add_2d(v1: Vector2d, v2: Vector2d) -> (r: Vector2d) {
    alloc_locals;

    local res: Vector2d;
    assert res.x = v1.x + v2.x;
    assert res.y = v1.y + v2.y;

    return (r=res);
}

func main{output_ptr: felt*}() {
    let v1 = Vector2d(x=1, y=2);
    let v2 = Vector2d(x=3, y=4);

    let (sum) = add_2d(v1, v2);

    serialize_word(sum.x);
    serialize_word(sum.y);

    return ();
}
