# The Manhatthon Project

A basic Python 3 compiler made as part of CS335 (2023-24  II semester).
Done by Pranjal Singh, Deven Anil Gangawani and Dev Gupta.

## Description

- Uses GNU `flex` and `bison` for lexical and grammar specifications.
- Processes a subset of Python 3 (statically typed, among other omissions).
- `milestone1/doc/doc.pdf` contains further details.

## Usage

- The output of the parser is a `dot` file, not a PDF, as per the specification
- We use GNU `make` for convenience and to generate the AST automatically. `milestone1/doc/doc.pdf` contains detailed instructions.
- `make test` compiles `input.py` (if it is present), generates `ast.dot` and `temp.pdf` and cleans the intermediate files and the binary.
- `make parser` generates only the parser and intermediate files (`parser`, `parser.tab.c`, `parser.tab.h` and `lex.yy.c`).
- Command-line options are specified in `milestone1/doc/doc.pdf`. Alternatively, run `make parser` and then use the help flag: `./parser -help`.
