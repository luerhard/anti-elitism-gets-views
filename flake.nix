{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/7ffd9ae656aec493492b44d0ddfb28e79a1ea25d";
    flake-utils.url = "github:numtide/flake-utils";
    # does not work although this version has MacOS support according to nixhub.io
    # failing on dm-tree 0.1.8 / tensorflow-2.13.0 : marked as broken
    # spacypkgs.url = "github:NixOS/nixpkgs/1839883cd0068572aed75fb9442b508bbd9ef09c"; # v 3.7.6
    # spacypkgs.url = "github:NixOS/nixpkgs/fcb54ddcc974cff59bdfb7c1ac9e080299763d2d"; # v 3.7.5
    # spacypkgs.url = "github:NixOS/nixpkgs/61684d356e41c97f80087e89659283d00fe032ab"; # v 3.7.4
    spacypkgs.url = "github:NixOS/nixpkgs/458b097d81f90275b3fdf03796f0563844926708"; # v 3.7.3
    # 2.5.1 + 2.5.0 is broken in linux due to triton 3.1.0 build fail
    # torchpkgs.url = "github:NixOS/nixpkgs/ca30f584e18024baf39c395001262ed936f27ebd"; # v 2.4.1
    torchpkgs.url = "github:NixOS/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269"; # v 2.4.0

    # try to fix reticulate openSSL problem with different ibis version?
    # ibis works fine in python but breaks with "could not find OPENSSL_3_0_0" if called from reticulate
    # ibispkgs.url = "github:NixOS/nixpkgs/189e5f171b163feb7791a9118afa778d9a1db81f"; # v 9.1.0
    ibispkgs.url = "github:NixOS/nixpkgs/4a4ecb0ab415c9fccfb005567a215e6a9564cdf5"; # v 9.0.0

    # platformdirs should be <4.0 for dvc - otherwise a permission denied error on /var/cache/dvc occurs
    # https://github.com/iterative/dvc/issues/9184
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      spacypkgs,
      torchpkgs,
      ibispkgs,
      ...
    }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" ] (
      system:
      let

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        spacy = import spacypkgs { inherit system; };
        ibis = import ibispkgs { inherit system; };
        torch = import torchpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
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
            with torch;
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
          tidyverse
        ];

        # weird work around to due ibis-framework packaging in python "extras"
        # normal command would be pip install 'ibis-framework[duckdb]'
        python_ibis_framework = (
          ibis.python311Packages.ibis-framework.overrideAttrs (old: {
            propagatedBuildInputs = (
              old.propagatedBuildInputs
              ++ [
                ibis.python311Packages.pyarrow
                ibis.python311Packages.pyarrow-hotfix
                ibis.python311Packages.duckdb
                ibis.python311Packages.datafusion
              ]
            );
            doCheck = false;
            doInstallCheck = false;
          })
        );

        # torch has a series of problems.
        python_pytorch = torch.python311Packages.torch-bin;
        # spacy needs to be installed from another commit to use a version that works on darwin..
        python_spacy = spacy.python311Packages.spacy;

        mypython = pkgs.python311.withPackages (ppkgs: with ppkgs; [
          ipykernel
          matplotlib
          levenshtein
          pandas
          papermill
          pip # important for reticulate
          rpy2
          transformers
          tqdm
    ]);

      in
      {
        defaultPackage = pkgs.mkShell {
          packages = [
            mypython
            python_ibis_framework
            python_pytorch
            python_spacy
            system_deps
            linux_cuda_deps
            r_env
          ];

          ld_lib_path = if system == "x86_64-linux" then "${pkgs.linuxPackages.nvidia_x11}/lib" else "";
          env_python_path = mypython;

          shellHook = ''

            export work_dir=$(pwd)
            export LD_LIBRARY_PATH="$ld_lib_path:$LD_LIBRARY_PATH"
            export PYTHONPATH="$work_dir:$env_python_path"
            export RETICULATE_PYTHON=$(which python)

          '';
        };
      }
    );
}
