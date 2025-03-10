# Simple build automation (Simba)

Generates a `configure` and a `Makefile.in`. With the use of these 2
files I aim to reproduce a similar experience found in GNU Autotools
at least in terms of the interface between the user and the "build
system". Indeed, a very limited set of the core patterns found in GNU
AutoTools is consciously implemented, the use of `m4` in particular is
limited to a supporting role. The programmer is expected to write
their own build system in any language they like, only the foundation
is provided.

Executing `simba` generates 2 files:

```sh
simba
# -> ./configure
# -> ./Makefile.in
```

The building of a project should be thought to be comprised of 2 phases:

- configuration time
- build time

The user is expected to shape the configuration stage by modifying the
`configure` script and the build stage through the `Makefile.in`.

## Getting Started

### Prerequisites

### Installation

### Configuration

## Usage

### Examples

## Contributing

Submit a pull request

## Contact

pavlos.noulis@gmail.com
