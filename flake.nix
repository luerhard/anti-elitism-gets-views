{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/18cd1b9484ae394b3ce08bcbeab50895011f517c";
    flake-utils.url = "github:numtide/flake-utils";
    # does not work although this version has MacOS support according to nixhub.io
    # failing on dm-tree 0.1.8 / tensorflow-2.13.0 : marked as broken
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" ] (
      system:
      let

        wandb_overlay = final: prev: rec {
          python312 = prev.python312.override {
            packageOverrides = pyfinal: pyprev: {
              wandb = pyprev.buildPythonPackage rec {
                pname = "wandb";
                version = "0.19.5";
                format = "wheel";
                src = builtins.fetchurl {
                  url = "https://files.pythonhosted.org/packages/8a/30/8c495234e584ebcea92ec1d178897beeaf9798835bbb4f2b9a31c6533985/wandb-0.19.5-py3-none-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
                  sha256 = "0f8be456cbe819e8202009cf4ac10a5a28141c4c6370f34b3f8cbd640c2dc8f9";
                };
                propagatedBuildInputs = [
                  prev.python312.pkgs.click
                  prev.python312.pkgs.docker-pycreds
                  prev.python312.pkgs.gitpython
                  prev.python312.pkgs.platformdirs
                  prev.python312.pkgs.protobuf
                  prev.python312.pkgs.psutil
                  prev.python312.pkgs.pyyaml
                  prev.python312.pkgs.requests
                  prev.python312.pkgs.sentry-sdk_2
                  prev.python312.pkgs.setproctitle
                  prev.python312.pkgs.setuptools
                ];
              };
            multiprocessing-logging = pyprev.buildPythonPackage rec {
              pname = "multiprocessing-logging";
              version = "0.3.4";
              format = "wheel";
              src = builtins.fetchurl {
                url = "https://files.pythonhosted.org/packages/9e/fe/32bd864bcb604b0607924a4cf618ed267a0ef21ac9c3e255109256046e1f/multiprocessing_logging-0.3.4-py2.py3-none-any.whl";
                sha256 = "8a5be02b02edbd6fa6e3e89499af7680db69db9e2d8707fcd28d445fa248f23e";
              };
              propagatedBuildInputs = [
              ];
            };
            };
          };
        };

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = true;
          };
           overlays = [
            wandb_overlay
          ];
        };

        system_deps = with pkgs; [
          git
          glibcLocales # get rid of error msgs "unable to set locale -- default to 'C'"
          R
          pandoc
          ruff
          dvc
          pre-commit
        ];


        linux_cuda_deps =
          if system == "x64_64-linux" then
            with pkgs;
            [
              cudatoolkit
              linuxPackages.nvidia_x11
              cudaPackages.cudnn
            ]
          else
            [ ];

          r_env = with pkgs.rPackages; [
          box
          effects
          ggeffects
          ggpubr
          here
          irr
          jsonlite
          languageserver
          marginaleffects
          sjPlot
          MASS
          reticulate
          svglite
          # tidyverse
        ];

        py_env = pkgs.python312.withPackages (ppkgs: with ppkgs; [
          ipykernel
          matplotlib
          multiprocessing-logging
          levenshtein
          pandas
          papermill
          pip
          pytest
          pytest-cases
          wandb
          rpy2
          spacy
          somajo
          sqlalchemy
          torch-bin
          transformers
          tqdm
          yt-dlp
        ]);

      in
      {
        defaultPackage = pkgs.mkShell {
          packages = [
            py_env
            r_env
            linux_cuda_deps
            system_deps
          ];

          ld_lib_path = if system == "x86_64-linux" then "${pkgs.linuxPackages.nvidia_x11}/lib" else "";

          shellHook = ''

            export work_dir=$(pwd)
            export LD_LIBRARY_PATH="$ld_lib_path:$LD_LIBRARY_PATH"
            # export PYTHONPATH="$work_dir:$env_python_path"
            export RETICULATE_PYTHON=$(which python)

          '';
        };
      }
    );
}
