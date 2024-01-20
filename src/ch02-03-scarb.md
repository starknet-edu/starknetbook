# Scarb: The Package Manager

To make the most of this chapter, a basic grasp of the Cairo programming
language is advised. We suggest reading chapters 1-6 of the [Cairo
Book](https://book.cairo-lang.org/title-page.html), covering topics from
_Getting Started_ to _Enums and Pattern Matching._ Follow this by
studying the [Starknet Smart Contracts
chapter](https://book.cairo-lang.org/ch99-00-starknet-smart-contracts.html)
in the same book. With this background, you’ll be well-equipped to
understand the examples presented here.

Scarb is Cairo’s package manager designed for both Cairo and Starknet
projects. It handles dependencies, compiles projects, and integrates
with tools like Foundry. It is built by the same team that created
Foundry for Starknet.

# Scarb Workflow

Follow these steps to develop a Starknet contract using Scarb:

1.  **Initialize:** Use `scarb new` to set up a new project, generating
    a `Scarb.toml` file and initial `src/lib.cairo`.

2.  **Code:** Add your Cairo code in the `src` directory.

3.  **Dependencies:** Add external libraries using `scarb add`.

4.  **Compile:** Execute `scarb build` to convert your contract into
    Sierra code.

Scarb simplifies your development workflow, making it efficient and
streamlined.

# Installation

Scarb is cross-platform, supporting macOS, Linux, and Windows. For
installation, refer to the [Basic installation guide](./ch02-01-basic-installation).

# Cairo Project Structure

Next, we’ll dive into the key components that make up a Cairo project.

## Cairo Packages

Cairo packages, also referred to as "crates" in some contexts, are the
building blocks of a Cairo project. Each package must follow several
rules:

- A package must include a `Scarb.toml` file, which is Scarb’s
  manifest file. It contains the dependencies for your package.

- A package must include a `src/lib.cairo` file, which is the root of
  the package tree. It allows you to define functions and declare used
  modules.

Package structures might look like the following case where we have a
package named `my_package`, which includes a `src` directory with the
`lib.cairo` file inside, a `snips` directory which in itself a package
we can use, and a `Scarb.toml` file in the top-level directory.

    my_package/
    ├── src/
    │   ├── module1.cairo
    │   ├── module2.cairo
    │   └── lib.cairo
    ├── snips/
    │   ├── src/
    │   │   ├── lib.cairo
    │   ├── Scarb.toml
    └── Scarb.toml

Within the `Scarb.toml` file, you might have:

    [package]
    name = "my_package"
    version = "0.1.0"

    [dependencies]
    starknet = ">=2.0.1"
    snips = { path = "snips" }

Here starknet and snips are the dependencies of the package. The
`starknet` dependency is hosted on the Scarb registry (we do not need to
download it), while the `snips` dependency is located in the `snips`
directory.

# Setting Up a Project with Scarb

To create a new project using Scarb, navigate to your desired project
directory and execute the following command:

    $ scarb new hello_scarb

This command will create a new project directory named `hello_scarb`,
including a `Scarb.toml` file, a `src` directory with a `lib.cairo` file
inside, and initialize a new Git repository with a `.gitignore` file.

    hello_scarb/
    ├── src/
    │   └── lib.cairo
    └── Scarb.toml

Upon opening `Scarb.toml` in a text editor, you should see something
similar to the code snippet below:

    [package]
    name = "hello_scarb"
    version = "0.1.0"

    # See more keys and their definitions at https://docs.swmansion.com/scarb/docs/reference/manifest.html
    [dependencies]
    # foo = { path = "vendor/foo" }

# Building a Scarb Project

Clear all content in `src/lib.cairo` and replace with the following:

    // src/lib.cairo
    mod hello_scarb;

Next, create a new file titled `src/hello_scarb.cairo` and add the
following:

    // src/hello_scarb.cairo
    use debug::PrintTrait;
    fn main() {
        'Hello, Scarb!'.print();
    }

In this instance, the `lib.cairo` file contains a module declaration
referencing _hello_scarb_, which includes the _hello_scarb.cairo_
file’s implementation. For more on modules, imports, and the `lib.cairo`
file, please refer to the cairo-book on [Managing Cairo Projects in Chapter
7](https://book.cairo-lang.org/ch07-00-managing-cairo-projects-with-packages-crates-and-modules.html).

Scarb mandates that your source files be located within the `src`
directory.

To build (compile) your project from your `hello_scarb` directory, use
the following command:

    scarb build

This command compiles your project and produces the Sierra code in the
`target/dev/hello_scarb.sierra.json` file. Sierra serves as an intermediate
layer between high-level Cairo and compilation targets such as Cairo
Assembly (CASM). To understand more about Sierra, check out this
[article](https://medium.com/nethermind-eth/under-the-hood-of-cairo-1-0-exploring-sierra-7f32808421f5/).

To remove the build artifacts and delete the target directory, use the
`scarb clean` command.

## Adding Dependencies

Scarb facilitates the seamless management of dependencies for your Cairo
packages. Here are two methods to add dependencies to your project:

- Edit Scarb.toml File

Open the Scarb.toml file in your project directory and locate the
`[dependencies]` section. If it doesn’t exist, add it. To include a
dependency hosted on a Git repository, use the following format:

    [dependencies]
    alexandria_math = { git = "https://github.com/keep-starknet-strange/alexandria.git" }

For consistency, it’s recommended to pin Git dependencies to specific
commits. This can be done by adding the `rev` field with the commit
hash:

    [dependencies]
    alexandria_math = { git = "https://github.com/keep-starknet-strange/alexandria.git", rev = "81bb93c" }

After adding the dependency, remember to save the file.

- Use the scarb add Command

Alternatively, you can use the `scarb add` command to add dependencies
to your project. Open your terminal and execute the following command:

    $ scarb add alexandria_math --git https://github.com/keep-starknet-strange/alexandria.git

This command will add the alexandria_math dependency from the specified
Git repository to your project.

To remove a dependency, you can use the `scarb rm` command.

Once a dependency is added, the Scarb.toml file will be automatically
updated with the new dependency information.

## Using Dependencies in Your Code

After dependencies are added to your project, you can start utilizing
them in your Cairo code.

For example, let’s assume you have added the alexandria_math
dependency. Now, you can import and utilize functions from the
alexandria_math library in your `src/hello_scarb.cairo` file:

    // src/hello_scarb.cairo
    use alexandria_math::fibonacci;

    fn main() -> felt252 {
        fibonacci::fib(0, 1, 10)
    }

In the above example, we import the fibonacci function from the
alexandria_math library and utilize it in the main function.

# Scarb Cheat Sheet

Here’s a quick cheat sheet of some of the most commonly used Scarb
commands:

- `scarb new <project_name>`: Initialize a new project with the given
  project name.

- `scarb build`: Compile your Cairo code into Sierra code.

- `scarb add <dependency> --git <repository>`: Add a dependency to
  your project from a specified Git repository.

- `scarb rm <dependency>`: Remove a dependency from your project.

- `scarb run <script>`: Run a custom script defined in your
  `Scarb.toml` file.

# What is new since version 2.3.0

- JSON containing Sierra code of Starknet contract class becomes: `contract.contract_class.json`.
- JSON containing CASM code of Starknet contract class becomes: `contract.compiled_contract_class.json`.
- Now cairo supports `Components`. They are modular add-ons encapsulating reusable logic, storage, and events that can be incorporated into multiple contracts. They can be used to extend a contract's functionality, without having to reimplement the same logic over and over again.

## Project using Components

One of the most important features since `scarb 2.3.0` version is `Components`. Think of components as Lego blocks. They allow you to enrich your contracts by plugging in a module that you or someone else wrote.

Lets see and example. Recover our project from [Testnet Deployment](./ch02-05-testnet-deployment.md) section. We used the `Ownable-Starknet` example to interact with the blockchain, now we are going to use the same project, but we will refactor the code in order to use `components`

This is how our smart contract looks now

```rust
// ...rest of the code

#[starknet::component]
mod ownable_component {
    use super::{ContractAddress, IOwnable};
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        owner: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTransferred: OwnershipTransferred
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[embeddable_as(Ownable)]
    impl OwnableImpl<
        TContractState, +HasComponent<TContractState>
    > of IOwnable<ComponentState<TContractState>> {
        fn transfer_ownership(
            ref self: ComponentState<TContractState>, new_owner: ContractAddress
        ) {
            self.only_owner();
            self._transfer_ownership(new_owner);
        }
        fn owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn only_owner(self: @ComponentState<TContractState>) {
            let owner: ContractAddress = self.owner.read();
            let caller: ContractAddress = get_caller_address();
            assert(!caller.is_zero(), 'ZERO_ADDRESS_CALLER');
            assert(caller == owner, 'NOT_OWNER');
        }

        fn _transfer_ownership(
            ref self: ComponentState<TContractState>, new_owner: ContractAddress
        ) {
            let previous_owner: ContractAddress = self.owner.read();
            self.owner.write(new_owner);
            self
                .emit(
                    OwnershipTransferred { previous_owner: previous_owner, new_owner: new_owner }
                );
        }
    }
}

#[starknet::contract]
mod ownable_contract {
    use ownable_project::ownable_component;
    use super::{ContractAddress, IData};

    component!(path: ownable_component, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::Ownable<ContractState>;

    impl OwnableInternalImpl = ownable_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        data: felt252,
        #[substorage(v0)]
        ownable: ownable_component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnableEvent: ownable_component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.ownable.owner.write(initial_owner);
        self.data.write(1);
    }
    #[external(v0)]
    impl OwnableDataImpl of IData<ContractState> {
        fn get_data(self: @ContractState) -> felt252 {
            self.data.read()
        }
        fn set_data(ref self: ContractState, new_value: felt252) {
            self.ownable.only_owner();
            self.data.write(new_value);
        }
    }
}
```

Basically we decided to apply `components` on the section related to `ownership` and created a separated module `ownable_component`. Then we kept the `data` section in our main module `ownable_contract`.

To get the full implementation of this project, navigate to the `src/` directory in the [examples/Ownable-Components](https://github.com/starknet-edu/starknetbook/examples/Ownable-Components) directory of the Starknet Book repo. The `src/lib.cairo` file contains the contract to practice with.

After you get the full code on your machine, open your terminal, input `scarb build` to compile it, deploy your contract and call functions.

You can learn more about components in [Chapter 12 of The Cairo Book](https://book.cairo-lang.org/ch99-01-05-00-components.html).

Scarb is a versatile tool, and this is just the beginning of what you
can achieve with it. As you gain more experience in the Cairo language
and the Starknet platform, you’ll discover how much more you can do with
Scarb.

To stay updated on Scarb and its features, be sure to check the
[official Scarb
documentation](https://docs.swmansion.com/scarb/docs.html) regularly.
Happy coding!

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
