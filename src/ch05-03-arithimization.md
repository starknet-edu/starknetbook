The goal of the STARK protocol is to verify computations succinctly and
transparently. It follows three steps:

1.  The first step in a STARK is called *arithmetization*, and it is the
    translation (often referred to as *`reduction`*) of the problem of
    verifying a computation to the problem of checking that a certain
    polynomial, which can be evaluated efficiently on the verifier’s
    side (this is the *`succinctly`* part), is of low degree.
    Arithmetization is useful since it enables the use of tools from the
    realm of Error Correction Codes that efficiently test low
    degree-ness.

2.  However, arithmetization itself only translates a Computational
    Integrity statement into a polynomial, setting the scene for the
    next phase in STARK, which is another interactive protocol that
    involves a prover that attempts to convince a verifier that the
    polynomial is indeed of low degree. The verifier is convinced that
    the polynomial is of low degree if and only if the original
    computation is correct (except for an infinitesimally small
    probability).

3.  In the last step of STARK, the interactive protocol is transformed
    into a single non-interactive proof, that can be posted to a
    blockchain and publicly verified by anyone.

Arithmetization itself is composed of two steps. The first is generating
an execution trace and polynomial constraints, the second is
transforming these two objects into a single low-degree polynomial. In
terms of prover-verifier interaction, what really goes on is that the
prover and the verifier agree on what the polynomial constraints are in
advance. The prover then generates an execution trace, and in the
subsequent interaction, the prover tries to convince the verifier that
the polynomial constraints are satisfied over this execution trace,
unseen by the verifier. Let’s review each step.

# Step 1: Generating an execution trace and a set of polynomial constraints

The first step takes some CI statement (such as
"`the fifth transaction in block 7218290 is correct`"), and translate it
into formal algebraic language. This serves two purposes: 1) it defines
the claim succinctly in an unambiguous way, and 2) it embeds the claim
in an algebraic domain. This embedding is what allows the second step of
arithmetization, which reduces the CI statement to a claim about the
degree of a specific polynomial.

The algebraic representation that we use has two main components: 1) an
execution trace, and 2) a set of polynomial constraints. The execution
trace is a table that represents the steps of the underlying
computation, where each row represents a single step. The set of
polynomial constraints is constructed such that all of them are
satisfied if and only if the trace represents a valid computation. While
the execution trace may be very long, we will work with a succinct set
of polynomial constraints.

The type of execution trace that we’re looking to generate must have the
special trait of being succinctly testable — each row can be verified
relying only on rows that are close to it in the trace, and the same
verification procedure is applied to each pair of rows. This trait
directly affects the size of the proof. To exemplify what we mean by
being succinctly testable, let’s go back to the supermarket receipt, and
add another column for the running total:

<figure>
<img src="receipt2.png" alt="receipt2" />
</figure>

This simple addition allows us to verify each row individually, given
its previous row.

We can, for example, examine these two rows:

<figure>
<img src="receipt3.png" alt="receipt3" />
</figure>

We would be convinced that this particular step of the computation (i.e.
the number 16.41) is correct since 12.96+3.45=16.41. Notice that the
same constraint is applied to each pair of rows. This is what we mean by
succinct constraints.

Let’s proceed with the polynomial constraints. We rewrite the
supermarket receipt (with the running total) in the form of a table:

<figure>
<img src="receipt4.png" alt="receipt4" />
</figure>

Denote the value of the cell in the $i$-th row and $j$-th column by
$A\_{i,j}$. We can now rephrase the correctness conditions as this set
of polynomial constraints:

<figure>
<img src="constraints.png" alt="constraints" />
</figure>

These are linear polynomial constraints in Ai,j. If the set of
polynomial constraints we use are of high degree, this has an adverse
effect on the proof length and the time it takes to generate it.
Consequently, linear constraints are the best we can hope for. Notice
that (2) is really a single constraint applied multiple times, and the
whole size of the set is independent of the length of the receipt.

In sum, we took a CI problem of verifying a supermarket receipt, and
transformed it into a succinctly testable execution trace, and a
corresponding set of polynomial constraints that hold if and only if the
total sum in the original receipt is correct.

Let’s see a more complex example: the Collatz Conjecture.

In 1937, a German mathematician named Lothar Collatz presented a
conjecture in the field of number theory. At first glance this
conjecture might seem merely a cute math puzzle, but in fact it is a
hard open problem in number theory. It caught the attention of many
mathematicians over the years, and acquired a lot of synonyms (e.g., the
$3n + 1$ conjecture, the Ulam conjecture, Kakutani’s problem and many
more). Paul Erdős once said about this conjecture:
"`Mathematics may not be ready for such problems`".

A Collatz sequence starts with any positive integer, where each
subsequent element in the sequence is obtained from the previous one as
follows:

If the previous element is even: divide it by 2. If the previous element
is odd and greater than 1: multiply it by 3 and add 1. If the previous
element is 1, stop. Let’s consider a simple example where the initial
term is 52:

$52 -&gt; 26 -&gt; 13 -&gt; 40 -&gt; 20 -&gt; 10 -&gt; 5 -&gt; 16 -&gt;
8 -&gt; 4 -&gt; 2 -&gt; 1$.

**Collatz Conjecture**: for any positive integer we start with, the
sequence always reaches 1.

Unfortunately, resolving the Collatz Conjecture is beyond the scope of
this tutorial. Instead, we will consider the problem of verifying a
computation that checks the conjecture for a particular starting
integer.

The Collatz Sequence Execution Trace The CI statement is:
"`A Collatz sequence that starts with 52, ends with 1 after 11 iterations`".

Let A be the execution trace of the sequence’s computation. The i-th
row, denoted by Ai, represents the i-th number in the sequence. All
numbers are represented as binary strings, to make it easier to express
the odd/even condition with polynomials. Ai,j equals to the j-th least
significant bit of the i-th number of the sequence. For example,
A0=001011: the first term is 52, its binary representation is 110100 and
then we reverse the bits\`' order (bit reversal order simplifies
indexing in the polynomial constraints notation).

Here is the execution trace of the above Collatz sequence that starts
with 52:

<figure>
<img src="collatz.png" alt="collatz" />
</figure>

Note that here the trace has 6 columns because 6 bits are enough to
represent even the largest number in the sequence. Had we started the
sequence with 51, the next number would have been 154, so the trace of
such a sequence would have required at least 8 columns.

Recall that the polynomial constraints we are looking for are such that
all of them are satisfied if and only if the trace A describes the given
Collatz sequence (starting with 52, ending with 1, and the transition
from any two consecutive rows is done correctly). In our example, the
trace A is of size 6x12, i.e., it represents a Collatz sequence of 12
6-bit numbers. The set of polynomial constraints are the following
($n=12$, $m=6$):

<figure>
<img src="collatz2.png" alt="collatz2" />
</figure>

Let’s go over each of the constraints. The first three are
straightforward:

1.  holds if and only if the first row is a binary representation of 52.

2.  holds if and only if the last row is a binary representation of 1.

3.  holds if and only if the trace contains only bits (a number is equal
    to its square if and only if it is either 0 or 1).

The fourth set of constraints defines the heart of the succinct
computation of the sequence, i.e., the connection between every two
consecutive rows. The ability to express computational constraints as a
recurring pattern of local constraints (i.e. succinctness), is
fundamental to the verifier being exponentially faster than a naive
replay of the computation.

Let’s examine the constraints themselves carefully.

For any $i&lt;n-1$, denote:

<figure>
<img src="collatz3.png" alt="collatz3" />
</figure>

Hence, for each $i&lt;n-1$, we get the following constraint:

<figure>
<img src="collatz4.png" alt="collatz4" />
</figure>

$A\_{i,0}$ is the least significant bit of the $i$-th number, which
determines its parity as an integer, so this constraint describes the
Collatz sequence rule.

To sum up, all constraints are satisfied if and only if the trace
represents a valid computation of a Collatz sequence.

Note that any Collatz sequence of length n, can be represented using a
trace of size n\*m where m is the maximum number of bits in the
representation of a number in the sequence, and the corresponding
polynomial constraints are modified accordingly. Note that the
polynomial constraints do not grow with n and m, but remain simple and
concise.

Given a specific first term for a Collatz sequence, a simple computer
program can output the execution trace and the polynomial constraints.
We have seen how a CI statement about a Collatz sequence can be
transformed into an execution trace and a succinctly-described set of
polynomial constraints. Similar methods can be used to transform any
computation, and in general, any CI statement can be translated into
this form.

The details, however, matter a great deal. While there are many ways in
which an execution trace (and a set of polynomial constraints) may
describe a specific computation, only a handful of them result in a
small STARK proof which can be constructed efficiently. Much of the
effort in Starkware is devoted to designing reductions that lead to good
polynomial constraints, which we call AIR (Algebraic Intermediate
Representation), as much of the performance of our systems depends on
it.

# Step 2: Transform the execution trace and the set of polynomial constraints into a single low-degree polynomial

Using a Fibonacci sequence, we will show how the prover can combine the
execution trace and the polynomial constraints to obtain a polynomial
that is guaranteed to be of low degree if and only if the execution
trace satisfies the polynomial constraints that we started with.
Moreover, we will show how the domain over which the polynomial is
considered allows the verifier to evaluate it succinctly. We also
briefly discuss how error correction codes play a role in STARKs.

Recall that our goal is to make it possible for a verifier to ask a
prover a very small number of questions, and decide whether to accept or
reject the proof with a guaranteed high level of accuracy. Ideally, the
verifier would like to ask the prover to provide the values in a few
(random) places in the execution trace, and check that the polynomial
constraints hold for these places. A correct execution trace will
naturally pass this test. However, it is not hard to construct a
completely wrong execution trace, that violates the constraints only at
a single place, and, doing so, reach a completely far and different
outcome. Identifying this fault via a small number of random queries is
highly improbable.

Common techniques that address similar problems are [**Error Correction
Codes**](https://en.wikipedia.org/wiki/Error_detection_and_correction).

Error Correction Codes transform a set of strings, some of which may be
very similar to one another, into a set of strings that are pairwise
very different, by replacing the original strings with longer strings.

Interestingly, polynomials can be used to construct good error
correction codes, since two polynomials of degree d, evaluated on a
domain that is considerably larger than $d$, are different almost
everywhere (to see this, notice that the difference between distinct
degree-$d$ polynomials is a non-zero polynomial of degree $d$, hence has
at most $d$ zeros). Such codes are called **Reed-Solomon** codes.

Observing that, we can extend the execution trace by thinking of it as
an evaluation of a polynomial on some domain, and evaluating this same
polynomial on a much larger domain. Extending in a similar fashion an
incorrect execution trace, results in a vastly different string, which
in turn makes it possible for the verifier to distinguish between these
cases using a small number of queries.

Our plan is therefore to 1) rephrase the execution trace as a
polynomial, 2) extend it to a large domain, and 3) transform that, using
the polynomial constraints, into yet another polynomial that is
guaranteed to be of low degree if and only if the execution trace is
valid.

**Toy Example: Boolean Execution Trace**

Suppose that the CI statement in question is
"`The prover has a sequence of 512 numbers, all of which are either 0 or 1`",
which we would like to verify by reading substantially less than 512
numbers. Let’s see what kind of execution trace and polynomial
constraints express this toy example:

1.  The execution trace has $512$ rows, each row containing a single
    cell with either zero or one in it.

2.  The polynomial constraint we use here is simply
    $A\_\\ᵢ}⋅A\_\\ᵢ}-A\_\\ᵢ}=0$, where $A\_\\ᵢ}$ denotes the $i$-th cell
    in this single-column execution trace (a number is equal to its
    square if and only if it is either 0 or 1).

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td style="text-align: left;"></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>G</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>=512$, and some generator $g$ of $G$.
The existence of such a subgroup is guaranteed since $512$ divides the
size of this group (which is $96768$).</p></td>
</tr>
</tbody>
</table>

We now think of the elements in the execution trace as evaluations of
some polynomial f(x) of degree less than 512 in the following way: the
i-th cell contains the evaluation of f on the generator’s i-th power.

Formally:

<figure>
<img src="generator.png" alt="generator" />
</figure>

Such a polynomial of degree at most 512 can be computed by
interpolation, and we then proceed to evaluate it on a much larger
domain (choosing this domain’s size directly translates into the
soundness error, the bigger it is — the smaller the soundness error),
forming a special case of Reed-Solomon codeword.

Lastly, we use this polynomial to create another one, whose low
degreeness depends on the constraint being satisfied over the execution
trace.

To do so, we must go on a tangent and discuss roots of polynomials.

A basic fact about polynomials and their roots is that if $p(x)$ is a
polynomial, then $p(a)=0$ for some specific value $a$, if and only if
there exists a polynomial $q(x)$ such that $(x-a)q(x)=p(x)$, and
$deg(p)=deg(q)+1$.

Moreover, for all $x≠a$, we can evaluate $q(x)$ by computing:

<figure>
<img src="root.png" alt="root" />
</figure>

By induction, a similar fact is true for $k$ roots. Namely, if $a\_\\ᵢ}$
is a root of p for all $i=0..k-1$, then there exists a polynomial $q$ of
degree $deg(p)-k$, and in all but these $k$ values, it is exactly equal
to:

<figure>
<img src="kroots.png" alt="kroots" />
</figure>

Rephrasing the polynomial constraint in terms of f yields the following
polynomial:

<figure>
<img src="polConstraint.png" alt="polConstraint" />
</figure>

We have defined $f$ such that the roots of this expression are $1$, $g$,
$g²$, $…$, $g⁵¹¹$ if and only if the cells in the execution trace are
$0$ or $1$. We can define:

<figure>
<img src="polConstraint2.png" alt="polConstraint2" />
</figure>

If there exists a protocol by which the prover can convince (such that
the verifier is convinced if and only if the prover is not cheating) the
verifier that this polynomial is of low degree, such that in it the
verifier only asks for values outside the execution trace, then indeed
the verifier will be convinced about the truthfulness of the CI
statement only when it is true. In fact, in the next post, we will show
a protocol that does exactly that, with some very small probability of
error. For the time being — let’s take a look at another example, that
is still simple, but not completely trivial, and see how the reduction
works in that case.

**Not so trivial example: Fibonacci**

<figure>
<img src="fibonacci1.png" alt="fibonacci1" />
</figure>

We can create an execution trace for this CI statement by simply writing
down all 512 numbers:

<figure>
<img src="fibonacci2.png" alt="fibonacci2" />
</figure>

The polynomial constraints that we use are

<figure>
<img src="fibonacci3.png" alt="fibonacci3" />
</figure>

Now we translate into Polynomials.

Here, too, we define a polynomial $f(x)$ of degree at most $512$, such
that the elements in the execution trace are evaluations of $f$ in
powers of some generator $g$.

Formally:

<figure>
<img src="fibonacci4.png" alt="fibonacci4" />
</figure>

Expressing the polynomial constraints in terms of $f$ instead of $A$, we
get:

<figure>
<img src="fibonacci5.png" alt="fibonacci5" />
</figure>

Since a composition of polynomials is still a polynomial — substituting
the $Aᵢ$ in the constraints with $f(gⁱ)$ still means these are
polynomial constraints.

Note that 1, 2, and 4 are constraints that refer to a single value of
$f$, we refer to them as boundary constraints.

The Fibonacci recurrence relation, in contrast, embodies a set of
constraints over the entire execution trace, and it may be alternatively
rephrased as:

<figure>
<img src="fibonacci6.png" alt="fibonacci6" />
</figure>

The use of a generator to index the rows of the execution trace allows
us to encode the notion of "`next row`" as a simple algebraic relation.
If x is some row in the execution trace, then $gx$ is the next row,
$g²x$ is the row after that, $g⁻¹x$ is the previous row and so on.

The recurrence relation polynomial: $f(g²x)-f(gx)-f(x)$ is zero for
every $x$ that indexes a row in the execution trace, except for the last
two. It means that 1, $g$, $g²$, $…$, $g⁵⁰⁹$ are all roots of this
recurrence relation polynomial (and it is of degree at most 510), so we
can construct $q(x)$ as follows:

<figure>
<img src="fibonacci7.png" alt="fibonacci7" />
</figure>

In STARK lore, this is often referred to as the composition polynomial.
Indeed, when the original execution trace obeys the Fibonacci recurrence
relation, this expression agrees with some polynomial whose degree is at
most 2 (recall that the degree of f is at most 512) on all but these 510
values: 1, $g$, $g²$, $…$, $g⁵⁰⁹$. However, the term composition
polynomial is somewhat misleading, as when the execution trace does not
satisfy the polynomial constraint — the evaluations of this expression
differ from any low degree polynomial in many places. In other
words — it is close to a low-degree polynomial if and only if the
original CI is correct, which indeed was our goal.

This concludes the promised reduction, that translates the problem of
checking whether certain polynomial constraints are satisfied over some
execution trace, to the problem of checking whether some polynomial
(known to the prover) is of low degree.

Succinctness

Having a very efficient verification technique is key to STARKs, and it
can be seen as comprised of two parts — using a small number of queries,
and having the verifier perform a small computation on each query. The
former is achieved by error correction codes, which allow querying in
very few places, and the latter we have sort of swept under the rug
throughout this post, until now. The verifier’s work can be summed up
as 1) querying the composition polynomial in random places, and 2)
checking low-degreeness based on these queries. Low degreeness succinct
checking will be handled in the next post, but what exactly do we mean
by "`querying the composition polynomial`"? The avid reader may have
been suspicious of this expression, and rightfully so. The prover, after
all, may be malicious. When the verifier asks for the evaluation of the
composition polynomial at some x, the prover may reply with the
evaluation of some truly low-degree polynomial, that will pass any
low-degree testing, but is not the composition polynomial.

To prevent this, the verifier explicitly queries the Fibonacci execution
trace at some row w by asking for the values of $f$ in three places:
$f(w)$, $f(gw)$, $f(g²w)$.

The verifier can now compute the value of the composition polynomial at
w by:

<figure>
<img src="succinctness.png" alt="succintness" />
</figure>

Where the numerator can be computed using the values obtained from the
prover, and the denominator… well, there’s the rub (that was swept under
the rug).

On the one hand the denominator is completely independent of the
execution trace, so the verifier can compute it before ever
communicating with the prover.

On the other hand, in practicality — the trace may be comprised of
hundreds of thousands of rows, and computing the denominator would cost
the verifier dearly in running time.

Here’s where the arithmetization is crucial to succinctness — since
calculating this expression for the special case where the powers of g
form a subgroup can be done very efficiently if one notices that:

<figure>
<img src="succinctness2.png" alt="succinctness2" />
</figure>

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p>This equality is true because both
sides are polynomials of degree $</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>G</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>$ whose roots are exactly the elements
of $G$.</p></td>
</tr>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p>Computing the right hand side of this
equation seems to require a number of operations that is linear in
$</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>G</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>$. However, if we resort to <a
href="https://en.wikipedia.org/wiki/Exponentiation_by_squaring">exponentiation
by squaring</a>, the left hand side of this equation can be computed in
running time that is logarithmic in $</p></td>
</tr>
<tr class="even">
<td style="text-align: left;"><p>G</p></td>
</tr>
<tr class="odd">
<td style="text-align: left;"><p>$.</p></td>
</tr>
</tbody>
</table>

And the actual denominator of the Fibonacci composition polynomial in
question can be obtained by rewriting it as:

<figure>
<img src="succinctness3.png" alt="succinctness3" />
</figure>

This seeming technicality stands at the core of the verifier being able
to run in polylogarithmic time, and it is enabled only because we view
the execution trace as evaluations of a polynomial over some subgroup of
the field, and that the polynomial constraints in question hold over a
subgroup.

Similar tricks can be applied for more sophisticated execution traces,
but it is crucial that the repeating pattern of the constraint coincides
with some subgroup of the field.

More Constraints, More Columns!

The examples in this post were deliberately simple, to highlight key
aspects of arithmetization. A natural question that arises will be: how
is the case of multiple columns and multiple constraints handled. The
answer is straightforward: multiple columns simply mean that there’s
more than one polynomial to work with, and multiple composition
polynomials — resulting from the multiple constraints — are combined
into a single polynomial, a random linear combination of all of them,
for the sake of the last phase in STARK, which is a low degree test.
With high probability, the linear combination is of low degree if and
only if so are all of its components.

We have shown how, given an execution trace and constraint polynomials,
the prover can construct a polynomial which is of low degree if and only
if the original CI statement holds. Furthermore, we have shown how the
verifier can query the values of this polynomial efficiently, making
sure that the prover did not replace the true polynomial with some false
low-degree one.

Next we will go into the details of low-degree testing, showing how this
magic, of querying a small number of values and determining whether some
polynomial is of low degree, is done.

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
