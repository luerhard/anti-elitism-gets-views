# populism_on_yt

## Installation

The repositories' environments are managed with nix.
Use an existing nix installation to create the environment, running `nix develop --impure` from the root directory.

## Reproducing the pipeline

For a reproducible research model, this repository uses dvc.
Because I am not allowed to share the data freely, you will not be able to access the data respository.
For people with access to the Uni Stuttgart internal network, the pipeline can be run using `dvc repro`.

To do that you will need an external installation of dvc, which can, for example be installed using `uv tool install 'dvc[all]'`
