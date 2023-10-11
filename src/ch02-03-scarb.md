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
installation, refer to the [Chapter 1 setup
guide](https://book.starknet.io/chapter_1/environment_setup.html#the_scarb_package_manager_installation).

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
file, please refer to the subchapter on [imports in Chapter
2](https://book.starknet.io/chapter_2/imports.html).

Scarb mandates that your source files be located within the `src`
directory.

To build (compile) your project from your `hello_scarb` directory, use
the following command:

    scarb build

This command compiles your project and produces the Sierra code in the
`target/dev/hello_scarb.sierra` file. Sierra serves as an intermediate
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
