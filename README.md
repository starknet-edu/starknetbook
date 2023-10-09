# The Starknet Book

This repository hosts the source for [The Starknet Book](book.starknet.io).

## Contribution

We value and welcome all contributions!

- For insight into specific areas of focus, check [the repository issues](https://github.com/starknet-edu/starknetbook/issues).
- Prioritize contributions that directly pertain to the book's content.
- Even if an issue doesn't exist, feel free to create a PR for typos, errors, or content improvements and additions.

## Building the Book

Before building or contributing to the book:

- Ensure you have [mdBook] installed. While version 0.4.31 is recommended, newer versions should be compatible.

```bash
$ cargo install mdbook --version 0.4.31
```

Follow these steps to build and view the book:

1. Build the book:
    
```bash
$ mdbook build    
```
    
2. After building, the compiled content will be located in the **`book`** subdirectory.
3. To view the content in a browser:
    
```bash
$ mdbook serve --open    
```    
Tip: After making edits, simply refresh your browser to see the updates.
    