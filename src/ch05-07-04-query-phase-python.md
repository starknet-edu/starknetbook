*Copyright 2019 Starkware Industries Ltd. Licensed under the Apache
License, Version 2.0 (the "License"). You may not use this file except
in compliance with the License. You may obtain a copy of the License at
<https://www.starkware.co/open-source-license/> Unless required by
applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for
the specific language governing permissions and limitations under the
License.*

# Part 4: Query Phase

-   [Video Lecture
    (youtube)](https://www.youtube.com/watch?v=CxP28qM4tAc)

-   [Slides
    (PDF)](https://starkware.co/wp-content/uploads/2021/12/STARK101-Part4.pdf)

# Load the Previous Session

Run the next cell to load the variables we’ll use in this part. Since it
repeats everything done in previous parts - it will take a while to run.

    from channel import Channel
    from tutorial_sessions import part1, part3

    _, _, _, _, _, _, _, f_eval, f_merkle, _ = part1()
    fri_polys, fri_domains, fri_layers, fri_merkles, _ = part3()

    print('Success!')

# Decommit on a Query

Our goal in this part is to generate all the information needed for
verifying the commitments of the three previous parts. In this part we
write two functions:

1.  `decommit_on_fri_layers` - sends over the channel data showing that
    each FRI layer is consistent with the others, when sampled at a
    specified index.

2.  `decommit_on_query` - sends data required for decommiting on the
    trace and then calls `decommit_on_fri_layers`.

# Decommit on the FRI Layers

Implement `decommit_on_fri_layers` function. The function gets an index
and a channel, and sends over the channel the relevant data for
verifying the correctness of the FRI layers. More specifically, it
iterates over `fri_layers` and `fri_merkles` and in each iteration it
sends the following data (in the stated order):

1.  The element of the FRI layer at the given index (using
    `fri_layers`).

2.  Its authentication path (using the corresponding Merkle tree from
    `fri_merkles`).

3.  The element’s FRI sibling (i.e., if the element is , then its
    sibling is , where is the current layer’s polynomial, and is an
    element from the current layer’s domain).

4.  The authentication path of the element’s sibling (using the same
    merkle tree).

To get an authentication path of an element, use
`get_authentication_path()` of the `MerkleTree` class, with the
corresponding index each time. Note that the index of the element’s
sibling equals to (idx + ) mod , where is the length of the relevant FRI
layer. Note that we do **not** send the authentication path for the
element in the last layer. In the last layer, all the elements are
equal, regardless of the query, as they are evaluations of a constant
polynomial.

*(Remember to convert non-string variables into string before sending
over the channel.)*

Solution:

    def decommit_on_fri_layers(idx, channel):
        for layer, merkle in zip(fri_layers[:-1], fri_merkles[:-1]):
            length = len(layer)
            idx = idx % length
            sib_idx = (idx + length // 2) % length
            channel.send(str(layer[idx]))
            channel.send(str(merkle.get_authentication_path(idx)))
            channel.send(str(layer[sib_idx]))
            channel.send(str(merkle.get_authentication_path(sib_idx)))
        channel.send(str(fri_layers[-1][0]))

Test your code:

    # Test against a precomputed hash.
    test_channel = Channel()
    for query in [7527, 8168, 1190, 2668, 1262, 1889, 3828, 5798, 396, 2518]:
        decommit_on_fri_layers(query, test_channel)
    assert test_channel.state == 'ad4fe9aaee0fbbad0130ae0fda896393b879c5078bf57d6c705ec41ce240861b', 'State of channel is wrong.'
    print('Success!')

# Decommit on the Trace Polynomial

To prove that indeed the FRI layers we decommit on were generated from
evaluation of the composition polynomial, we must also send:

1.  The value with its authentication path.

2.  The value with its authentication path.

3.  The value with its authentication path. The verifier, knowing the
    random coefficients of the composition polynomial, can compute its
    evaluation at , and compare it with the first element sent from the
    first FRI layer.

The function `decommit_on_query` should therefore send the above (1, 2,
and 3) over the channel, and then call `decommit_on_fri_layers`.

Importantly, even though are consecutive elements (modulo the group size
) in the trace, the evaluations of `f_eval` in these points are actually
8 elements apart. The reason for this is that we "blew up" the trace to
8 times its size in part I, to obtain a Reed Solomon codeword.

*Reminder: `f_eval` is the evaluation of the composition polynomial, and
`f_merkle` is the corresponding Merkle tree.*

Solution:

    def decommit_on_query(idx, channel):
        assert idx + 16 < len(f_eval), f'query index: {idx} is out of range. Length of layer: {len(f_eval)}.'
        channel.send(str(f_eval[idx])) # f(x).
        channel.send(str(f_merkle.get_authentication_path(idx))) # auth path for f(x).
        channel.send(str(f_eval[idx + 8])) # f(gx).
        channel.send(str(f_merkle.get_authentication_path(idx + 8))) # auth path for f(gx).
        channel.send(str(f_eval[idx + 16])) # f(g^2x).
        channel.send(str(f_merkle.get_authentication_path(idx + 16))) # auth path for f(g^2x).
        decommit_on_fri_layers(idx, channel)

Test your code:

    # Test against a precomputed hash.
    test_channel = Channel()
    for query in [8134, 1110, 1134, 6106, 7149, 4796, 144, 4738, 957]:
        decommit_on_query(query, test_channel)
    assert test_channel.state == '16a72acce8d10ffb318f8f5cd557930e38cdba236a40439c9cf04aaf650cfb96', 'State of channel is wrong.'
    print('Success!')

# Decommit on a Set of Queries

To finish the proof, the prover gets a set of random queries from the
channel, i.e., indices between 0 to 8191, and decommits on each query.

Use the function that you just implemented `decommit_on_query()`, and
`Channel.receive_random_int` to generate 3 random queries and decommit
on each.

Solution:

    def decommit_fri(channel):
        for query in range(3):
            # Get a random index from the verifier and send the corresponding decommitment.
            decommit_on_query(channel.receive_random_int(0, 8191-16), channel)

Test your code:

    test_channel = Channel()
    decommit_fri(test_channel)
    assert test_channel.state == 'eb96b3b77fe6cd48cfb388467c72440bdf035c51d0cfe8b4c003dd1e65e952fd', 'State of channel is wrong.'
    print('Success!')

# Proving Time!

Run the following cell that ties it all together, running all previous
code, as well as the functions you wrote in this part, and prints the
proof.

    import time
    from tutorial_sessions import part1, part3

    start = time.time()
    start_all = start
    print("Generating the trace...")
    _, _, _, _, _, _, _, f_eval, f_merkle, _ = part1()
    print(f'{time.time() - start}s')
    start = time.time()
    print("Generating the composition polynomial and the FRI layers...")
    fri_polys, fri_domains, fri_layers, fri_merkles, channel = part3()
    print(f'{time.time() - start}s')
    start = time.time()
    print("Generating queries and decommitments...")
    decommit_fri(channel)
    print(f'{time.time() - start}s')
    start = time.time()
    print(channel.proof)
    print(f'Overall time: {time.time() - start_all}s')
    print(f'Uncompressed proof length in characters: {len(str(channel.proof))}')
