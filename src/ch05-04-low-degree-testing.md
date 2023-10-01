The process of Arithmetization enabled us to reduce the CI problem to a
low degree testing problem. Low degree testing refers to the problem of
deciding whether a given function is a polynomial of some bounded
degree, by making only a small number of queries to the function. Low
degree testing has been studied for more than two decades, and is a
central tool in the theory of probabilistic proofs. The goal of this
blog post is to explain low degree testing in more detail, and to
describe FRI, the protocol that we use for low degree testing in STARK.
This post assumes familiarity with polynomials over finite fields.

Before we discuss low-degree testing, we first present a slightly
simpler problem as a warm-up: We are given a function and are asked to
decide whether this function is equal to some polynomial of degree less
than some constant d, by querying the function at a "`small`" number of
locations. Formally, given a subset L of a field F and a degree bound d,
we wish to determine if $f:L➝F$ is equal to a polynomial of degree less
than $d$, namely, if there exists a polynomial

<figure>
<img src="low1.png" alt="low1" />
</figure>

over $F$ for which $p(a) = f(a)$ for every $a$ in $L$. For concrete
values, you may think of a field of size which is very large, say
$2¹²⁸$, and $L$ which is of size approximately 10,000,000.

Solving this problem requires querying $f$ at the entire domain $L$, as
f might agree with a polynomial everywhere in $L$ except for a single
location. Even if we allow a constant probability of error, the number
of queries will still be linear in the size of $L$.

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p>For this reason, the problem of low
degree testing actually refers to an approximate relaxation of the above
problem, which suffices for constructing probabilistic proofs and also
can be solved with a number of queries which is logarithmic in
$</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>L</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>$ (note that if $L≈10,000,000$, then
$log₂(L)≈23)$. In more detail, we wish to distinguish between the
following two cases.</p></td>
</tr>
</tbody>
</table>

-   **The function $f$ is equal to a low degree polynomial**. Namely,
    there exists a polynomial $p(x)$ over $F$, of degree less than $d$,
    that agrees with $f$ everywhere on $L$.

-   **The function $f$ is far from ALL low degree polynomials**. For
    example, we need to modify at least 10% of the values of $f$ before
    we obtain a function that agrees with a polynomial of degree less
    than $d$.

Note that there is another possibility — the function $f$ may be mildly
close to a low degree polynomial, yet not equal to one. For example, a
function in which $5%$ of the values differ from a low-degree polynomial
does not fall in either of the two cases described above. However, the
prior arithmetization step (discussed in our previous posts) ensures the
third case never arises. In more detail, arithmetization shows that an
honest prover dealing with a true statement will land in the first case,
whereas a (possibly malicious) prover attempting to "`prove`" a false
claim will land, with high probability, in the second case.

In order to distinguish the two cases, we will use a probabilistic
polynomial-time test that queries f at a small number of locations (we
discuss what "`small`" means later).

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p>This paragraph is optional for
understanding the big picture. If $f$ is indeed low degree, then the
test should accept with probability 1. If instead f is far from low
degree, then the test should reject with high probability. More
generally, we seek the guarantee that if f is $δ-far$ from any function
of degree less than d (i.e., one must modify at least $δ</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>L</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>$ locations to obtain a polynomial of
degree less than d), then the test rejects with probability at least
$Ω(δ)$ (or some other "<code>nice</code>" function of $δ$). Intuitively,
the closer $δ$ is to zero, the more difficult it is to distinguish
between the two cases.</p></td>
</tr>
</tbody>
</table>

In the next few sections we describe a simple test, then explain why it
does not suffice in our setting, and finally we describe a more complex
test that is exponentially more efficient. This latter test is the one
that we use in STARK.

# The Direct Test

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p>The first test we consider is a simple
one: it tests whether a function is (close to) a polynomial of degree
less than $d$, using $d+1$ queries. The test relies on a basic fact
about polynomials: any polynomial of degree less than d is fully
determined by its values at any d distinct locations of $F$. This fact
is a direct consequence of the fact that a polynomial of degree $k$ can
have at most $k$ roots in $F$. Importantly, the number of queries, which
is $d+1$, can be significantly less than the size of the domain of $f$,
which is $</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>L</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>$.</p></td>
</tr>
</tbody>
</table>

We first discuss two simple special cases, to build intuition for how
the test will work in the general case.

-   **The case of a constant function $(d=1)$.** This corresponds to the
    problem of distinguishing between the case where $f$ is a constant
    function ($f(x)=c$ for some $c$ in $F$), and the case where $f$ is
    far from any constant function. In this special case there is a
    natural 2-query test that might work: query $f$ at a fixed location
    $z1$ and also at a random location $w$, and then check that
    $f(z1)=f(w)$. Intuitively, $f(z1)$ determines the (alleged) constant
    value of $f$, and $f(w)$ tests whether all of $f$ is close to this
    constant value or not.

-   **The case of a linear function $(d=2)$.** This corresponds to the
    problem of distinguishing between the case where $f$ is a linear
    function ($f(x)=ax+b$ for some $a$,$b$ in $F$), and the case where
    $f$ is far from any linear function. In this special case there is a
    natural 3-query test that might work: query f at two fixed locations
    z1,z2 and also at a random location $w$, and then check that
    ($z1$,$f(z1)$), ($z2$,$f(z2)$), ($w$,$f(w)$) are collinear, namely,
    we can draw a line through these points. Intuitively, the values of
    $f(z1)$ and $f(z2)$ determine the (alleged) line, and $f(w)$ tests
    whether all of $f$ is close to this line or not.

The above special cases suggest a test for the general case of a degree
bound $d$. Query $f$ at $d$ fixed locations $z1$,$z2$,$…$,$zd$ and also
at a random location $w$. The values of $f$ at $z0$,$z1$,$…$,$zd$ define
a unique polynomial $h(x)$ of degree less than $d$ over $F$ that agrees
with $f$ at these points. The test then checks that $h(w)=f(w)$. We call
this the direct test.

By definition, if $f(x)$ is equal to a polynomial $p(x)$ of degree less
than $d$, then $h(x)$ will be identical to $p(x)$ and thus the direct
test passes with probability 1. This property is called
"`perfect completeness`", and it means that this test has only 1-sided
error.

We are left to argue what happens if $f$ is $δ$-far from any function of
degree less than $d$. (For example, think of $δ=10%$.) We now argue
that, in this case, the direct test rejects with probability at least δ.
Indeed, let 𝞵 be the probability, over a random choice of w, that
$h(w)≠f(w)$. Observe that $𝞵$ must be at least δ. Optional: This is
because if we assume towards contradiction that 𝞵 is smaller than δ,
then we deduce that f is δ-close to h, which contradicts our assumption
that f is δ-far from any function of degree less than d.

# The Direct Test Does Not Suffice For Us

In our setting we are interested in testing functions f:L➝F that encode
computation traces, and hence whose degree d (and domain L) are quite
large. Merely running the direct test, which makes d+1 queries, would be
too expensive. In order to gain the exponential savings of STARK (in
verification time compared to the size of the computation trace), we
need to solve this problem with only O(log d) queries, which is
exponentially less than the degree bound d.

This, unfortunately, is impossible because if we query f at less than
d+1 locations then we cannot conclude anything.

Optional: One way to see this is to consider two different distributions
of functions f:L➝F. In one distribution we uniformly pick a polynomial
of degree exactly d and evaluate it on L. In the other distribution we
uniformly pick a polynomial of degree less than d and evaluate it on L.
In both cases, for any d locations z1,z2,…,zd, the values
f(z1),f(z2),…,f(zd) are uniformly and independently distributed. (We
leave this fact as an exercise for the reader.) This implies that
information-theoretically we cannot tell these two cases apart, even
though a test would be required to (since polynomials from the first
distribution should be accepted by the test while those of degree
exactly d are very far from all polynomials of degree less than d, and
thus should be rejected).

We seem to have a difficult challenge to overcome.

# A Prover Comes to the Rescue

We have seen that we need d+1 queries to test that a function f:L➝F is
close to a polynomial of degree less than d, but we cannot afford this
many queries. We avoid this limitation by considering a slightly
different setting, which suffices for us. Namely, we consider the
problem of low degree testing when a prover is available to supply
useful auxiliary information about the function f. We will see that in
this "`prover-aided`" setting of low-degree testing we can achieve an
exponential improvement in the number of queries, to O(log d).

In more detail, we consider a protocol conducted between a prover and a
verifier, wherein the (untrusted) prover tries to convince the verifier
that the function is of low degree. On the one hand, the prover knows
the entire function f being tested. On the other hand, the verifier can
query the function f at a small number of locations, and is willing to
receive help from the prover, but does NOT trust the prover to be
honest. This means that the prover may cheat and not follow the
protocol. However, if the prover does cheat, the verifier has the
liberty to "`reject`", regardless of whether the function f is of low
degree or not. The important point here is that the verifier will not be
convinced that f is of low degree unless this is true.

Note that the direct test described above is simply the special case of
a protocol in which the prover does nothing, and the verifier tests the
function unassisted. To do better than the direct test we will need to
leverage the help of the prover in some meaningful way.

Throughout the protocol the prover will want to enable the verifier to
query auxiliary functions on locations of the verifier’s choice. This
can be achieved via commitments, a mechanism that we will discuss in a
future blog post. For now it suffices to say that the prover can commit
to a function of its choice via a Merkle tree, and subsequently the
verifier can request the prover to reveal any set of locations of the
committed function. The main property of this commitment mechanism is
that once the prover commits to a function, it must reveal the correct
values and cannot cheat (for example, it cannot decide what the values
of the function are after seeing the requests from the verifier).

# Halving the number of queries for the case of two polynomials

Let’s start with a simple example that illustrates how a prover can help
to reduce the number of queries by a factor of 2. We will later build on
this example. Suppose that we have two polynomials f and g and we want
to test that they are both of degree less than d. If we simply run the
direct test individually on f and g then we would need to make 2 \*
(d + 1) queries. Below we describe how with the help of a prover we can
reduce the number of queries to (d + 1) plus a smaller-order term.

First, the verifier samples a random value 𝛼 from the field and sends it
to the prover. Next, the prover replies by committing to the evaluation
on the domain L (recall that L is the domain of the function f) of the
polynomial h(x) = f(x) + 𝛼 g(x) (in other words, the prover will compute
and send the root of a Merkle tree whose leaves are the values of h on
L). The verifier now tests that h has degree less than d, via the direct
test, which requires d+1 queries.

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p>Intuitively, if f or g has degree at
least d, then with high probability so does h. For example, consider the
case where the coefficient of xⁿ in f is not zero for some n≥d. Then,
there is at most one choice of 𝛼 (sent by the verifier) for which the
coefficient of xⁿ in h is zero, which means that the probability that h
has degree less than d is roughly 1/</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>F</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>. If the field is large enough
(say,</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>F</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>&gt;2¹²⁸), the probability of error is
negligible.</p></td>
</tr>
</tbody>
</table>

The situation, however, is not this simple. The reason is that, as we
explained, we cannot literally check that h is a polynomial of degree
less than d. Instead we only can check that h is close to such a
polynomial. This means that the analysis above is not accurate. Is it
possible that f will be far from a low degree polynomial and the linear
combination h will be close to one with a non-negligible probability
over 𝛼? Under mild conditions the answer is no (which is what we want),
but it is outside the scope for this post; we refer the interested
reader to [this paper](https://acmccs.github.io/papers/p2087-amesA.pdf)
and [this paper](https://eccc.weizmann.ac.il/report/2017/134/).

Moreover, how does the verifier know that the polynomial h sent by the
prover has the form f(x)+𝛼 g(x)? A malicious prover may cheat by sending
a polynomial which is indeed of low degree, but is different from the
linear combination that the verifier asked for. If we already know that
h is close to a low degree polynomial, then testing that this low degree
polynomial has the correct form is straightforward: the verifier samples
a location z in L at random, queries f, g, h at z, and checks that the
equation h(z)=f(z)+𝛼 g(z) holds. This test should be repeated multiple
times to increase accuracy of the test, but the error shrinks
exponentially with the number of samples we make. Hence this step
increases the number of queries (which so far was d+1) only by a
smaller-order term.

# Splitting a polynomial into two smaller-degree polynomials

We saw that, with the prover’s help, we can test that two polynomials
are of degree less than d with less than 2\*(d+1) queries. We now
describe how we can turn one polynomial of degree less than d into two
polynomials of degree less than d/2.

Let f(x) be a polynomial of degree less than d and assume that d is even
(in our setting this comes without loss of generality). We can write
f(x)=g(x²)+xh(x²) for two polynomials g(x) and h(x) of degree less than
d/2. Indeed, we can let g(x) be the polynomial obtained from the even
coefficients of f(x), and h(x) be the polynomial obtained from the odd
coefficients of f(x). For example, if d=6 we can write

<figure>
<img src="smallerPol1.png" alt="smallerPol1" />
</figure>

which means that

<figure>
<img src="smallerPol2.png" alt="smallerPol2" />
</figure>

and

<figure>
<img src="smallerPol3.png" alt="smallerPol3" />
</figure>

which is an n\*log(n) algorithm for polynomial evaluation (improving
over the naive n2 algorithm).

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
