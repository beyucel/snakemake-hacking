# snakemake-hacking

Snakemake workflow for pymks fiber notebook.

## How to run

To test the evironment with a single step workflow

    $ nix-shell --pure
    $ cd Snakefiles
    $ snakemake --cores=1 --force
