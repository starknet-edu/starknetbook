# The Starknet Book

This repository contains the source for [The Starknet Book](book.starknet.io).

## Contribution

Every contribution, regardless of its size, plays a pivotal role in refining this work. Together, we advance the Starknet narrative.

- **General Guidelines**:
  - Focus on enhancements directly related to the book's content.
  - For typos, errors, or improvements, you don't need a related issue to submit a PR.
  - Review specific areas of interest in [the repository issues](https://github.com/starknet-edu/starknetbook/issues).

### Setup

1. **Rust Packages**:
   - Install the `cargo` toolchain via [rustup](https://rustup.rs/).
   - Install [mdBook](https://rust-lang.github.io/mdBook/guide/installation.html) and its translation extension:

```shell
cargo install mdbook --version 0.4.31 && cargo install mdbook-i18n-helpers --version 0.1.0
```

2. **Machine Packages**:

- For translations, install [gettext](https://www.gnu.org/software/gettext/): `sudo apt install gettext`.
- On Mac, you can use `brew install gettext` to install.

3. **Repository Operations**:

- Clone the main repository: `git clone https://github.com/starknet-edu/starknetbook && cd starknetbook`.
- Create and work on a branch in your fork. If you're unfamiliar, use this [guide](https://akrabat.com/the-beginners-guide-to-contributing-to-a-github-project/) for assistance.
- Once done, submit a PR to merge your edits. Ensure you tag a reviewer for feedback (`l-henri` or `@omarespejel`).

### Understanding the Book's Structure

The Starknet Book is optimized for mdBook:

- `src/SUMMARY.md`: The book's structural outline. For adding chapters, modify this document.
- `src/`: This directory holds individual chapters. Each is a markdown file, like `ch35.md`. Use subdirectories for added resources.
- `book.toml`: The primary configuration file (regular contributors might not need to adjust this).

### Editing Guidelines

#### Work Locally in English

Ensure all edits to Markdown files are in English.

- Use `mdbook serve` to initiate a local server. Access the book at [localhost:3000](http://localhost:3000) or append `--open` to the command to launch a browser automatically: `mdbook serve --open`.
- After editing, refresh the browser to see updates. When satisfied, push your changes through a PR.

#### Translations

Targeting a global readership, this book will undergo translations over time.

- **Initial Version Always in English**: Always write files in the `src` directory in English. This consistency allows for smooth auto-translation.
- **Translation Process**:
- Launch a local server for the intended language, e.g., `./translations.sh es`. Without specifying a language, only English translations get extracted.
- Modify the translation file of interest, like `po/es.po`. Tools like [poedit](https://poedit.net/) can be beneficial.
- Commit changes only in the `po/xx.po` file. When opening a PR, start with the prefix `i18n`.

The translation work is inspired from [Comprehensive Rust repository](https://github.com/google/comprehensive-rust/blob/main/TRANSLATIONS.md).

##### Initiating a New Translation

For starting translations in a new language:

- Employ `./translations.sh new xx`, replacing `xx` with your language code. This action generates a language file.
- For updating the `xx.po` file, use `./translations.sh xx`.
- Avoid the above command if the `xx.po` file already exists (which means you are not initiating a new translation).
