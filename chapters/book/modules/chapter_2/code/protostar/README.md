# Protostar and Cairo 1.0

Protostar has always been a favorite with Cairo developers, and just like Cairo, it too has undergone some changes recently. This template covers some of the most important changes, and should help familiarize you with the new and improved version.

Some important take-aways from this lesson ... 

- Protostar currently allows you to compile and test Cairo 1.0 
- Multiple contracts can be included in a single Protostar build 
- The framework provides `cheatcodes` which streamline testing
 
## Why Protostar ?

There are two major ways to test Cairo smart contracts - you can test them in Cairo itself, or in Python. I prefer the Cairo approach since it means I do not have to deploy contracts everytime I test them OR have to worry about using a new language here.

In this case, we can also benefit massively from the cheatcodes made available to us by Protostar. These are ways to make mock functionality for a smart contract without having to go through the bottlenecks of the real system. Please read more  [here](https://docs.swmansion.com/protostar/docs/tutorials/cairo-1-support/compiling).

To learn best practices for testing, I highly recommend you take a look at the tests in `tests/test_erc20.cairo` and compare it with the original contract in `erc20/src/contracts/erc20.cairo`.

## Debugging Code

In order to debug code, it is very useful to be able to print out values or isolate errors in `match` statements. In order to be able to print out, please use - 

```
use array::ArrayTrait;
use array::ArrayTCloneImpl;
use array::SpanTrait;
use debug::PrintTrait;
use clone::Clone;

array.span().snapshot.clone().print(); // Print an array value
felt.print() // Print an individual value
```

You can also use match statements as mentioned over [here](https://docs.swmansion.com/protostar/docs/tutorials/cairo-1-support/cheatcodes/deploy#handling-deploy-errors). 

## Common Gotchas

- Each test has to be named with a `test_<further name>.cairo` so the framework can recognize and run it
- Test needs to be decorated with `#[test]`, be without parameters and have an assertion
- `contract_address_const::<0>()` address is the default caller
- A `Prank` needs to be used to change the caller address
- `u256` values need to be split into two felt252 values when invoking a call
- Protostar is not able to handle `#[external]` functions which emit an event for testing. Please wait for the next release.
