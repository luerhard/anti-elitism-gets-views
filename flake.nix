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
      torchpkgs,
      ibispkgs,
      ...
    }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" ] (
      system:
      let

        pkgs_ibis = import ibispkgs { inherit system; };
        pkgs_torch = import torchpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };

        # spacyOverlay = final: prev: rec {
        #   MyPython = prev.python311.override {
        #     packageOverrides = pyfinal: pyprev: {
        #       spacy = pyprev.spacy.overrideAttrs (_: rec {
        #         version = "3.8.4";
        #         pname = "spacy";
        #         format = "wheel";
        #         src = final.fetchPypi {
        #           inherit pname version format;
        #           dist = python;
        #           python = "py3";
        #           sha256 = "";
        #         };
        #       });
        #     };
        #   };
        #   self = final.MyPython;
        # };

        spacyOverlay = final: prev: rec {
          python311 = prev.python311.override {
            packageOverrides = pyfinal: pyprev: {
              spacy = pyprev.buildPythonPackage {
                version = "3.8.4";
                pname = "spacy";
                format = "wheel";
                src = builtins.fetchurl {
                  url = "https://files.pythonhosted.org/packages/f9/36/4f95922a22c32bd6fdda50ae5780c55b72d75ff76fd94cafa24950601330/spacy-3.8.4-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
                  sha256 = "4540e4599df47e2d7525b8da1515d29da72db339ba8553b2f8d30842179806ea";
                };

                propagatedBuildInputs = [
                  prev.python311.pkgs.catalogue
                  prev.python311.pkgs.cymem
                  prev.python311.pkgs.jinja2
                  prev.python311.pkgs.langcodes
                  prev.python311.pkgs.murmurhash
                  prev.python311.pkgs.numpy
                  prev.python311.pkgs.packaging
                  prev.python311.pkgs.preshed
                  prev.python311.pkgs.pydantic
                  prev.python311.pkgs.requests
                  prev.python311.pkgs.setuptools
                  prev.python311.pkgs.spacy-legacy
                  prev.python311.pkgs.spacy-loggers
                  prev.python311.pkgs.srsly
                  prev.python311.pkgs.thinc
                  prev.python311.pkgs.tqdm
                  prev.python311.pkgs.typer
                  prev.python311.pkgs.wasabi
                  prev.python311.pkgs.weasel
                ];
              };
            };
          };
        };

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ spacyOverlay ];
        };

        mypython = pkgs.python311.withPackages (ppkgs: [
          # ipykernel
          # matplotlib
          # levenshtein
          # pandas
          # papermill
          ppkgs.pytest
          ppkgs.spacy
          # pytest-cases
          # rpy2
          # sqlalchemy
          # pkgs_spacy.python311.pkgs.spacy
          # transformers
          # tqdm
          # yt-dlp
        ]);

      in
      {
        defaultPackage = pkgs.mkShell {
          packages = [
            mypython
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
