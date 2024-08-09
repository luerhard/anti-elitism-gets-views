# populism_on_yt

## R

### rig

R versions are managed using rig. Make sure to have version 4.2 selected. An easy way is to use `direnv`. To do that, install it add `eval "$(direnv hook zsh)` to `.zhsrc`.

Then, create a file `.envrc` in the project root with the content (fix paths):

```bash
export R_LIBS_USER="renv/library/R-4.2/aarch64-apple-darwin20"
export R_HOME="/Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/"
rig switch 4.2-arm64
layout_poetry
```

## renv
To use pak for renv::restore use env variable:

```bash
export RENV_CONFIG_PAK_ENABLED=true
rig run
renv::restore()
```

## Python

### poetry

poetry is used to manage python dependencies

```bash
poetry install
poetry run python
```
