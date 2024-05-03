# The Starknet Book

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->

[![All Contributors](https://img.shields.io/badge/all_contributors-35-orange.svg?style=flat-square)](#contributors-)

<!-- ALL-CONTRIBUTORS-BADGE:END -->

This repository contains the source for [The Starknet Book](https://book.starknet.io).

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

```bash
cargo install mdbook --version 0.4.31 && cargo install mdbook-i18n-helpers --version 0.1.0
```

2. **Machine Packages**:

- For translations, install [gettext](https://www.gnu.org/software/gettext/): `sudo apt install gettext`.
- On Mac, you can use `brew install gettext` to install.

3. **Repository Operations**:

- Clone the main repository: `git clone https://github.com/starknet-edu/starknetbook && cd starknetbook`.
- Create and work on a branch in your fork. If you're unfamiliar, use this [guide](https://akrabat.com/the-beginners-guide-to-contributing-to-a-github-project/) for assistance.
- Once done, submit a PR to merge your edits. Ensure you tag a reviewer for feedback (`@gianalarcon` or `@omarespejel`).

4. **Formatting**

- Run `npm i`
- Then after completing your documentation run `npm run format`
- Finally run `prettier --write .`

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

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/omarespejel"><img src="https://avatars.githubusercontent.com/u/4755430?v=4?s=100" width="100px;" alt="Omar U. Espejel"/><br /><sub><b>Omar U. Espejel</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=omarespejel" title="Code">💻</a> <a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=omarespejel" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/JameStark"><img src="https://avatars.githubusercontent.com/u/113911244?v=4?s=100" width="100px;" alt="JameStark"/><br /><sub><b>JameStark</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=JameStark" title="Code">💻</a> <a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=JameStark" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gianalarcon"><img src="https://avatars.githubusercontent.com/u/22782504?v=4?s=100" width="100px;" alt="GianMarco"/><br /><sub><b>GianMarco</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=gianalarcon" title="Code">💻</a> <a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=gianalarcon" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/drspacemn"><img src="https://avatars.githubusercontent.com/u/16685321?v=4?s=100" width="100px;" alt="drspacemn"/><br /><sub><b>drspacemn</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=drspacemn" title="Code">💻</a> <a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=drspacemn" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://gyanlakshmi.net/"><img src="https://avatars.githubusercontent.com/u/27683905?v=4?s=100" width="100px;" alt="Gyan"/><br /><sub><b>Gyan</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=gyan0890" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/stoobie"><img src="https://avatars.githubusercontent.com/u/39279277?v=4?s=100" width="100px;" alt="Steve Goodman"/><br /><sub><b>Steve Goodman</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=stoobie" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://david-barreto.com/"><img src="https://avatars.githubusercontent.com/u/2279046?v=4?s=100" width="100px;" alt="David Barreto"/><br /><sub><b>David Barreto</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=barretodavid" title="Documentation">📖</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/omahs"><img src="https://avatars.githubusercontent.com/u/73983677?v=4?s=100" width="100px;" alt="omahs"/><br /><sub><b>omahs</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=omahs" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/l-henri"><img src="https://avatars.githubusercontent.com/u/22731646?v=4?s=100" width="100px;" alt="Henri"/><br /><sub><b>Henri</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=l-henri" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/devnet0x"><img src="https://avatars.githubusercontent.com/u/117481421?v=4?s=100" width="100px;" alt="devnet0x"/><br /><sub><b>devnet0x</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=devnet0x" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cryptonerdcn"><img src="https://avatars.githubusercontent.com/u/97042744?v=4?s=100" width="100px;" alt="cryptonerdcn"/><br /><sub><b>cryptonerdcn</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=cryptonerdcn" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/LandauRaz"><img src="https://avatars.githubusercontent.com/u/125185051?v=4?s=100" width="100px;" alt="Raz Landau"/><br /><sub><b>Raz Landau</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=LandauRaz" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Nadai2010"><img src="https://avatars.githubusercontent.com/u/112663528?v=4?s=100" width="100px;" alt="Nadai"/><br /><sub><b>Nadai</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=Nadai2010" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/CyndieKamau"><img src="https://avatars.githubusercontent.com/u/63792575?v=4?s=100" width="100px;" alt="Cyndie Kamau"/><br /><sub><b>Cyndie Kamau</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=CyndieKamau" title="Documentation">📖</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/manmit-singh99/"><img src="https://avatars.githubusercontent.com/u/49245208?v=4?s=100" width="100px;" alt="Manmit Singh"/><br /><sub><b>Manmit Singh</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=SupremeSingh" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/remedcu"><img src="https://avatars.githubusercontent.com/u/30735581?v=4?s=100" width="100px;" alt="Shebin John"/><br /><sub><b>Shebin John</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=remedcu" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://livesoftwaredeveloper.com/"><img src="https://avatars.githubusercontent.com/u/49430208?v=4?s=100" width="100px;" alt="Dalmas Nyaboga Ogembo"/><br /><sub><b>Dalmas Nyaboga Ogembo</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=dalmasonto" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/codeWhizperer"><img src="https://avatars.githubusercontent.com/u/63842643?v=4?s=100" width="100px;" alt="Adegbite Ademola Kelvin"/><br /><sub><b>Adegbite Ademola Kelvin</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=codeWhizperer" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/robertkodra"><img src="https://avatars.githubusercontent.com/u/36516516?v=4?s=100" width="100px;" alt="Robert"/><br /><sub><b>Robert</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=robertkodra" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lorcan-codes"><img src="https://avatars.githubusercontent.com/u/126797224?v=4?s=100" width="100px;" alt="lorcan-codes"/><br /><sub><b>lorcan-codes</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=lorcan-codes" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/oboulant/"><img src="https://avatars.githubusercontent.com/u/12909374?v=4?s=100" width="100px;" alt="Olivier Boulant"/><br /><sub><b>Olivier Boulant</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=oboulant" title="Documentation">📖</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/LucasLvy"><img src="https://avatars.githubusercontent.com/u/70894690?v=4?s=100" width="100px;" alt="Lucas @ StarkWare"/><br /><sub><b>Lucas @ StarkWare</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=LucasLvy" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/OkoliEvans"><img src="https://avatars.githubusercontent.com/u/95226065?v=4?s=100" width="100px;" alt="Okoli Evans"/><br /><sub><b>Okoli Evans</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=OkoliEvans" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/estheroche"><img src="https://avatars.githubusercontent.com/u/125284347?v=4?s=100" width="100px;" alt="Esther Aladi Oche"/><br /><sub><b>Esther Aladi Oche</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=estheroche" title="Documentation">📖</a> <a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=estheroche" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/faytey"><img src="https://avatars.githubusercontent.com/u/40033608?v=4?s=100" width="100px;" alt="faytey"/><br /><sub><b>faytey</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=faytey" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ccolorado"><img src="https://avatars.githubusercontent.com/u/876976?v=4?s=100" width="100px;" alt="ccolorado"/><br /><sub><b>ccolorado</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=ccolorado" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Akinbola247"><img src="https://avatars.githubusercontent.com/u/112096641?v=4?s=100" width="100px;" alt="Akinbola Kehinde"/><br /><sub><b>Akinbola Kehinde</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=Akinbola247" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/LvisWang"><img src="https://avatars.githubusercontent.com/u/85268534?v=4?s=100" width="100px;" alt="Louis Wang"/><br /><sub><b>Louis Wang</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=LvisWang" title="Documentation">📖</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dbejarano820"><img src="https://avatars.githubusercontent.com/u/58019353?v=4?s=100" width="100px;" alt="Daniel Bejarano"/><br /><sub><b>Daniel Bejarano</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=dbejarano820" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dpinones"><img src="https://avatars.githubusercontent.com/u/30808181?v=4?s=100" width="100px;" alt="Damián Piñones"/><br /><sub><b>Damián Piñones</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=dpinones" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DavideSilva"><img src="https://avatars.githubusercontent.com/u/2940022?v=4?s=100" width="100px;" alt="Davide Silva"/><br /><sub><b>Davide Silva</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=DavideSilva" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/0xAsten"><img src="https://avatars.githubusercontent.com/u/114395459?v=4?s=100" width="100px;" alt="Asten"/><br /><sub><b>Asten</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=0xAsten" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Darlington02"><img src="https://avatars.githubusercontent.com/u/75126961?v=4?s=100" width="100px;" alt="Darlington Nnam"/><br /><sub><b>Darlington Nnam</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=Darlington02" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://nonnyjoe.github.io/my-portfolio/"><img src="https://avatars.githubusercontent.com/u/104998136?v=4?s=100" width="100px;" alt="Idogwu Emmanuel Chinonso"/><br /><sub><b>Idogwu Emmanuel Chinonso</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=Nonnyjoe" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/machuwey"><img src="https://avatars.githubusercontent.com/u/56169780?v=4?s=100" width="100px;" alt="machuwey"/><br /><sub><b>machuwey</b></sub></a><br /><a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=machuwey" title="Code">💻</a> <a href="https://github.com/The Starknet Community/The Starknet Book/commits?author=machuwey" title="Documentation">📖</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
