# Polymarketeer
This is a pet project, implementing a way for casual people to play with
Polymarket without real currency in OCaml.

This project uses `Core` heavily.

## Building the project
### Installation
1. Ensure you have [opam](https://opam.ocaml.org/doc/Install.html) and it is
   [initialised](https://ocaml.org/docs/installing-ocaml#initialise-opam).
2. Clone this repository with `git clone` and `cd` into it.
3. Install all dependencies with `opam install --deps-only .`.
   - Alternatively, `opam install` all dependencies manually as stated in the
     `depends` section of the `.opam` file, including `ocaml` and
     `dune`.
4. Run `dune build` to build the project to check that it is successful.

## Running the project
1. Run `dune exec -- ./bin/client.exe`.
