We now combine the two above ideas (testing two polynomials with half
the queries, and splitting a polynomial into two smaller ones) into a
protocol that only uses O(log d) queries to test that a function f has
(more precisely, is close to a function of) degree less than d. This
protocol is known as FRI (which stands for Fast Reed — Solomon
Interactive Oracle Proof of Proximity), and the interested reader can
read more about it [here](https://eccc.weizmann.ac.il/report/2017/134/).
For simplicity, below we assume that d is a power of 2. The protocol
consists of two phases: a commit phase and a query phase.

# Commit phase

The prover splits the original polynomial f₀(x)=f(x) into two
polynomials of degree less than d/2, g₀(x) and h₀(x), satisfying
f₀(x)=g₀(x²)+xh₀(x²). The verifier samples a random value 𝛼₀, sends it
to the prover, and asks the prover to commit to the polynomial
f₁(x)=g₀(x) + 𝛼₀h₀(x). Note that f₁(x) is of degree less than d/2.

We can continue recursively by splitting f₁(x) into g₁(x) and h₁(x),
then choosing a value 𝛼₁, constructing f₂(x) and so on. Each time, the
degree of the polynomial is halved. Hence, after log(d) steps we are
left with a constant polynomial, and the prover can simply send the
constant value to the verifier.

# Query phase

We now have to check that the prover did not cheat. The verifier samples
a random z in L and queries f₀(z) and f₀(-z). These two values suffice
to determine the values of g₀(z²) and h₀(z²), as can be seen by the
following two linear equations in the two "`variables`" g₀(z²) and
h₀(z²):

<figure>
<img src="query1.png" alt="query1" />
</figure>

The verifier can solve this system of equations and deduce the values of
g₀(z²) and h₀(z²). It follows that it can compute the value of f₁(z²)
which is a linear combination of the two. Now the verifier queries
f₁(z²) and makes sure that it is equal to the value computed above. This
serves as an indication that the commitment to f₁(x), which was sent by
the prover in the commit phase, is indeed the correct one. The verifier
may continue, by querying f₁(-z²) (recall that (-z²)∊ L² and that the
commitment on f₁(x) was given on L²) and deduce from it f₂(z⁴).

The verifier continues in this way until it uses all these queries to
finally deduce the value of f\_{log d}(z) (denoting f with a subscript
log d, that we can’t write due to Medium’s lack of support for fully
fledged mathematical notation). But, recall that f\_{log d}(z) is a
constant polynomial whose constant value was sent by the prover in the
commit phase, prior to choosing z. The verifier should check that the
value sent by the prover is indeed equal to the value that the verifier
computed from the queries to the previous functions.

Overall, the number of queries is only logarithmic in the degree bound
d.

Optional: To get a feeling why the prover cannot cheat, consider the toy
problem where f₀ is zero on 90% of the pairs of the form {z,-z}, i.e.,
f₀(z) = f₀(-z) = 0 (call these the "`good`" pairs), and non-zero on the
remaining 10% (the "`bad`" pairs). With probability 10% the randomly
selected z falls in a bad pair. Note that only one 𝛼 will lead to
f₁(z²)=0, and the rest will lead to f₁(z²)≠0. If the prover cheats on
the value of f₁(z²), it will be caught, so we assume otherwise. Thus,
with a high probability (f₁(z²), f₁(-z²)) will also be a bad pair in the
next layer (the value of f₁(-z²) is not important as f₁(z²)≠0). This
continues until the last layer where the value will be non-zero with
high probability.

On the other hand, since we started with a function with 90% zeros, it
is unlikely that the prover will be able to get close to a low degree
polynomial other than the zero polynomial (we will not prove this fact
here). In particular, this implies that the prover must send 0 as the
value of the last layer. But then, the verifier has a probability of
roughly 10% to catch the prover. This was only an informal argument, the
interested reader may find a rigorous proof
[here](https://eccc.weizmann.ac.il/report/2017/134/).

In summary, the direct solution (test) requires too many queries to
achieve the succinctness required by STARK. To attain logarithmic query
complexity, we use an interactive protocol called FRI, in which the
prover adds more information in order to convince the verifier that the
function is indeed of low degree. Crucially, FRI enables the verifier to
solve the low-degree testing problem with a number of queries (and
rounds of interaction) that is logarithmic in the prescribed degree.

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
