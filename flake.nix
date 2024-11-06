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

    # reticulate could not find openSSL 3.3.0 to load duckdb (dependency for ibis)
    # reticulatepkgs.url = "github:NixOS/nixpkgs/38d3352a65ac9d621b0cd3074d3bef27199ff78f"; # v 1.35.0
    # reticulatepkgs.url = "github:NixOS/nixpkgs/080a4a27f206d07724b88da096e27ef63401a504"; # v 1.34.0
    # reticulatepkgs.url = "github:NixOS/nixpkgs/52dc75a4fee3fdbcb792cb6fba009876b912bfe0"; # v 1.24.0
    # opensslpkgs.url = "github:NixOS/nixpkgs/2d2a9ddbe3f2c00747398f3dc9b05f7f2ebb0f53"; # v 3.3.2

    # try to fix reticulate openSSL problem with different ibis version?

    # dependencies could not be satisfied
    # ibispkgs.url = "github:NixOS/nixpkgs/189e5f171b163feb7791a9118afa778d9a1db81f"; # v 9.1.0
    ibispkgs.url = "github:NixOS/nixpkgs/4a4ecb0ab415c9fccfb005567a215e6a9564cdf5"; # v 9.0.0
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
          # trying to get rid of error msgs "unable to set locale -- default to 'C'"
          glibcLocales
          R
          pandoc
          python311
        ];

        linux_cuda_deps =
          if system == "x64_64-linux" then
            with torch;
            [
              # all for CUDA
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
          here
          irr
          jsonlite
          languageserver
          MASS
          reticulate
          svglite
          sjPlot
          tidyverse
        ];

        python_env = with pkgs.python311Packages; [
          ipykernel
          levenshtein
          openai
          pandas
          pip
          rpy2
          tqdm
        ];
      in
      {
        defaultPackage = pkgs.mkShell {
          buildInputs = [
            system_deps
            r_env
            python_env
            torch.python311Packages.torch-bin
            linux_cuda_deps
            # spacy needs to be installed from another commit to use a version that works on darwin..
            spacy.python311Packages.spacy
            # reticulate seems to have a problem with openssl in 1.38.0?
            # openssl.openssl_3_3

            # weird work around to due ibis-framework packaging in python "extras"
            (ibis.python311Packages.ibis-framework.overrideAttrs (old: {
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
            }))
          ];

          ld_lib_path = if system == "x86_64-linux" then "${pkgs.linuxPackages.nvidia_x11}/lib" else "";

          shellHook = ''
            export work_dir=$(pwd)

            export LD_LIBRARY_PATH="$ld_lib_path:$LD_LIBRARY_PATH"

            export PYTHONPATH="$work_dir:$PYTHONPATH"
            export RETICULATE_PYTHON=$(which python)

          '';
        };
      }
    );
}
