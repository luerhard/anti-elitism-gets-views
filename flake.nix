{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/1bde3e8e37a72989d4d455adde764d45f45dc11c";
    flake-utils.url = "github:numtide/flake-utils";
    nix-gl-host.url = "github:numtide/nix-gl-host";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-gl-host,
      ...
    }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" ] (
      system:
      let

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true; # necessary for CUDA
          };
          overlays = [
            (import ./nix/python-overlay.nix)
          ];
        };

        # general system dependencies
        systemDeps = with pkgs; [
          gcc
          git # so git works in terminal
          glibcLocales # get rid of error msgs "unable to set locale -- default to 'C'" in R
          R # necessary, otherwise no package is found in R
          pandoc
          ffmpeg
        ];

        # Linux CUDA deps.
        # Currently broken for python312 (?) Mismatch in driver version.
        linuxCudaDeps =
          if system == "x86_64-linux" then
            with pkgs;
            [
              cudatoolkit
              linuxPackages.nvidia_x11
              cudaPackages.cudnn
            ]
          else
            [ ];

        # all R packages go here
        rEnv = with pkgs.rPackages; [
          box
          effects
          ggeffects
          ggpubr
          lme4
          here
          irr
          jsonlite
          languageserver
          marginaleffects
          texreg
          sjPlot
          sjstats
          MASS
          reticulate
          svglite
          tidyverse
        ];

        # all python packages go here
        pyEnv = pkgs.python311.withPackages (
          ppkgs: with ppkgs; [
            ibis-framework
            ipykernel
            matplotlib
            multiprocessing-logging
            librosa
            levenshtein
            pandas
            papermill
            pip # important for reticulate
            pytest
            pytest-cases
            silero-vad
            wandb
            rpy2
            spacy
            somajo
            sqlalchemy
            torch-bin
            transformers
            tqdm
            yt-dlp
          ]
        );

      in
      {
        defaultPackage = pkgs.mkShell {
          packages = [
            pyEnv # needs to be @ top of list, so the correct python interpreter is exposed
            rEnv
            # linuxCudaDeps
            systemDeps
          ] ++ pkgs.lib.lists.optional pkgs.stdenv.isLinux [
            nix-gl-host.defaultPackage.${system}
          ];

          # ldLibPath = if system == "x86_64-linux" then "${pkgs.linuxPackages.nvidia_x11}/lib" else "";

          shellHook = ''
                      export PYTHONPATH="$(pwd):$PYTHONPATH"
                      export RETICULATE_PYTHON=$(which python)
            	  '';
        };
      }
    );
}
