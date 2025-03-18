# Simple build automation (Simba)

Simba is a library of utilities and a script that generates a build
system template. It is written in `bash`.

It depends on:

- bash
- make
- m4

It has been tested only on `linux` but might also run on `mac` if bash
is installed.

Anyhow, running ./configure will let you know which dependencies are
missing.

This project serves two purposes.

1. It contains some helpful utilities commonly needed across projects.

   One can easily `source` any simba utility they like since the files
   containing such reusable code under `src/` are copied over to the
   user's system.

   Their location depends on the value of the `DATADIR` variable at
   `make install` time.

   The default value of which is: `/usr/local/share/simba`

2. It contains a build system template.

   Executing `simba` generates a `configure` and a `Makefile.in`. With
   the use of these 2 files I aim to reproduce a similar experience
   found in [GNU Autotools](https://www.gnu.org/software/automake/manual/html_node/index.html)
   at least in terms of the interface between the user and the build
   system. Indeed, a very limited set of the core patterns found in
   GNU AutoTools is implemented; With the use of `m4` in particular
   delegated to a supporting role. The programmer is expected to write
   their own build system in any language they like, only the
   foundation is provided.


The building of a project should be thought to be comprised of 2 phases:

- configuration time
- build time

The user is expected to shape the configuration stage by modifying the
`configure` script and the build stage through the `Makefile.in`.

## Installation

```sh
# For a specific release
git clone --branch v1.0.0 --depth 1 git@github.com/pnoulis/simba.git

# For all releases including the @latest
git clone git@github.com/pnoulis/simba.git

# Ensures your system can actually install the program
./configure

# Install the program
sudo make install
```

## Configuration

Simba reads the users configuration file at:

`$HOME/.config/simba/simba.conf`

Any variable defined within this file shall be used by simba when
generating the build scripts.

In case it does not exist it shall copy over the template from
`DATADIR`.

## Usage

```sh
simba # -> simba generates a configure and Makefile.in at the current working directory
simba ./my-project # -> simba generates a configure and Makefile.in with 'my-project'
simba --help # -> an outline of the command and options
simba --version # -> get simba's installed version
```

## Contributing

Submit a pull request

## Contact

pavlos.noulis@gmail.com
