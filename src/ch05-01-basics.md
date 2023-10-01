By now there are quite a few theoretical constructions of proof systems,
along with implementations. Some are deployed in cryptocurrencies, like
the [SNARKs](https://z.cash/technology/zksnarks/) used by
[Zerocash](http://zerocash-project.org/paper), [Zcash](https://z.cash/),
and [Bulletproofs](https://eprint.iacr.org/2017/1066) (BP) deployed in
[Monero](https://ww.getmonero.org/). (For general information on proof
systems go [here](https://zkp.science/).) What distinguishes
[STARKs](https://eprint.iacr.org/2018/046) is the combination of the
following three properties: scalability (the S in STARK), transparency
(the T in STARK), and lean cryptography.

# Scalability: Exponential Speedup of Verification\*\*

Scalability means that two efficiency properties hold simultaneously:

-   **Scalable Prover**: The prover’s running time is "`nearly-linear`"
    in the time it would take a trusted computer to check CI by just
    re-executing the computation themselves and checking that the result
    matches what someone is claiming. The ratio of "`overhead`" (time
    needed to generate a proof / time needed to just run the
    computation) remains reasonably low.

-   **Scalable Verifier**: The verifier’s running time is polynomial in
    the logarithm of naive replay time. In other words, the verifier’s
    runtime is exponentially smaller than simply replaying the
    computation (recall that *`replay`* is the current blockchain method
    to achieve Inclusive Accountability).

<figure>
<img src="scalable.png" alt="scalable" />
</figure>

Apply this notion of scalability to a blockchain. Instead of the current
mode of verification by naive replay, imagine how things will look when
a blockchain moves to verification by using proof systems. Instead of
simply sending the transactions to be added to the blockchain, a prover
node will need to generate a proof but thanks to the Scalable Prover its
running time is nearly-linear in the running time of the naive replay
solution. And the Scalable Verifier will benefit from an exponential
decrease in its verification time. Furthermore, as blockchain throughput
scales up, most of the effect will be shouldered by the prover nodes
(which could run on dedicated hardware, like miners), whereas the
verifiers, which would constitute most of the nodes in the network,
would hardly be affected.

Let’s consider a concrete hypothetical example, assuming verifier time
(in milliseconds) scales like the square of the logarithm of the number
of transactions (tx). Suppose we start with 10,000 tx/block. Then the
verifier’s running time is

$VTime = (log₂ 10,000)² <sub>(13.2)²</sub> 177 ms$.

Now increase the blocksize a hundredfold (to 1,000,000 tx/block). The
new running time of the verifier is

$VTime = (log₂ 1,000,000)² <sub>20²</sub> 400 ms$.

In words, a 100x increase in transaction throughput led only to a 2.25x
increase in the verifier’s running time!

In some cases, the verifier will still need to download and verify
*availability of data*, which is a linear-time process, but downloading
data is generally much cheaper and faster than checking its validity.

# Transparency: With Trust Toward None, with Integrity for All

Transparency means there is no trusted setup (formally, a transparent
proof system is one in which all verifier messages are public random
strings. Such systems are also known as [Arthur-Merlin
protocols](https://en.wikipedia.org/wiki/Arthur%E2%80%93Merlin_protocol)) — there
is no use of secrets in the setting up of the system. Transparency
offers many benefits. It eliminates the parameter setup generation
procedure which constitutes a single point of failure. The lack of a
trusted setup allows even powerful entities — big corporations,
monopolies and governments, which control the "`old world`" financial
system — to prove CI and gain public acceptance of their claims because
there’s no known way to forge STARK proofs of falsities, even by the
most powerful of entities. On a more tactical level, it makes it much
easier to deploy new tools and infrastructure and change existing ones
without a need for elaborate parameter-generation ceremonies. Most
importantly, transparency aligns well with the "`new world`" that
demands Inclusive Accountability under no trust assumptions. [To
paraphrase Abraham
Lincoln](https://en.wikipedia.org/wiki/Abraham_Lincoln%27s_second_inaugural_address),
transparent systems allow to operate with trust toward none, with
integrity for all.

# Lean Cryptography: Secure & Fast

STARK has minimal cryptographic assumptions underlying its security: the
existence of secure cryptographic and [collision-resistant hash
functions](https://en.wikipedia.org/wiki/Collision_resistance) (this
minimality of cryptographic assumptions holds for interactive STARKs
(iSTARKs). Noninteractive STARKs (nSTARKs) require the Fiat-Shamir
heuristic which is a different beast). Many of these primitives exist
today as hardware instructions, and the lean cryptography leads to two
more benefits:

-   **Post-Quantum Security**: STARKs are plausibly secure against
    efficient quantum computers.

-   **Concrete Efficiency**: For a given computation, the STARK prover
    is at least 10x faster than both the SNARK and Bulletproofs prover.
    The STARK verifier is at least 2x faster than the SNARK verifier and
    more than 10x faster than the Bulletproof verifier. As Starkware
    continues to optimize STARKs these ratios will likely improve.
    However, a STARK proof length is
    <sub>100x\ larger\ than\ the\ corresponding\ SNARK\ and</sub> 20x
    larger than BulletProofs.

To understand how STARKs are computed, we need to delve into the
arithmetic of modular operations, finite fields, and polynomials. For
this we will need to touch mathematical concepts that at first glance
might seem complicated, however, you will see that it is easier than you
thought.

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
