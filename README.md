# populism_on_yt

## R

### rig

R versions are managed using rig. Make sure to have version 4.2 selected. An easy way is to use `direnv`. To do that, install it add `eval "$(direnv hook zsh)` to `.zhsrc`.

Then, create a file `.envrc` in the project root with the content:

```bash
# .renvrc
rig switch 4.2
# for macos arm
rig switch 4.2-arm64
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
