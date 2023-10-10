# The Starknet Book

This repository hosts the source for [The Starknet Book](book.starknet.io).

## Contribution

We value and welcome all contributions!

- For insight into specific areas of focus, check [the repository issues](https://github.com/starknet-edu/starknetbook/issues).
- Prioritize contributions that directly pertain to the book's content.
- Even if an issue doesn't exist, feel free to create a PR for typos, errors, or content improvements and additions.

### Setup
1. Rust related packages:
   - Install toolchain providing `cargo` using [rustup](https://rustup.rs/).
   - Install [mdBook](https://rust-lang.github.io/mdBook/guide/installation.html) and the translation extension:
   ```
   cargo install mdbook --version 0.4.31 mdbook-i18n-helpers --version 0.1.0
   ```
2. Host machine packages:
   - Install [gettext](https://www.gnu.org/software/gettext/) for translations, usually available with regular package manager:
     `sudo apt install gettext`.
3. Clone this repository.

### Work locally (english, main language)
All the Markdown files **MUST** be edited in english. To work locally in english:
- Start a local server with `mdbook serve` and visit [localhost:3000](http://localhost:3000) to view the book.
  You can use the `--open` flag to open the browser automatically: `mdbook serve --open`.
- Make changes to the book and refresh the browser to see the changes.
- Open a PR with your changes.
### Work locally (translations)
This book is targetting international audience, and aims at being gradually translated in several languages.
**All files in the `src` directory MUST be written in english**. This ensures that all the translation files can be
auto-generated and updated by translators.
To work with translations, those are the steps to update the translated content:
- Run a local server for the language you want to edit: `./translations.sh es` for instance. If no language is provided, the script will only extract translations from english.
- Open the translation file you are interested in `po/es.po` for instance. You can also use editors like [poedit](https://poedit.net/) to help you on this task.
- When you are done, you should only have changes into the `po/xx.po` file. Commit them and open a PR.
  The PR must stars with `i18n` to let the maintainers know that the PR is only changing translation.
The translation work is inspired from [Comprehensive Rust repository](https://github.com/google/comprehensive-rust/blob/main/TRANSLATIONS.md).
#### Initiate a new translation for your language
If you wish to initiate a new translation for your language without running a local server, consider the following tips:
- Execute the command `./translations.sh new xx` (replace `xx` with your language code). This method can generate the `xx.po` file of your language for you.
- To update your `xx.po` file, execute the command `./translations.sh xx` (replace `xx` with your language code), as mentioned in the previous chapter.
- If the `xx.po` file already exists (which means you are not initiating a new translation), you should not run this command.