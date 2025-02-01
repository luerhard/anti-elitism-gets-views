final: prev: rec {
    python311 = prev.python311.override {
        packageOverrides = pyfinal: pyprev: {

        # broken dependency of spacy, get newest version from PyPi
        wandb = pyprev.buildPythonPackage rec {
            pname = "wandb";
            version = "0.19.5";
            format = "wheel";
            src = builtins.fetchurl {
            url = "https://files.pythonhosted.org/packages/8a/30/8c495234e584ebcea92ec1d178897beeaf9798835bbb4f2b9a31c6533985/wandb-0.19.5-py3-none-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
            sha256 = "0f8be456cbe819e8202009cf4ac10a5a28141c4c6370f34b3f8cbd640c2dc8f9";
            };
            propagatedBuildInputs = [
            prev.python311.pkgs.click
            prev.python311.pkgs.docker-pycreds
            prev.python311.pkgs.gitpython
            prev.python311.pkgs.platformdirs
            prev.python311.pkgs.protobuf
            prev.python311.pkgs.psutil
            prev.python311.pkgs.pyyaml
            prev.python311.pkgs.requests
            prev.python311.pkgs.sentry-sdk_2
            prev.python311.pkgs.setproctitle
            prev.python311.pkgs.setuptools
            ];
        };

        # package not on nix-store
        multiprocessing-logging = pyprev.buildPythonPackage rec {
            pname = "multiprocessing-logging";
            version = "0.3.4";
            format = "wheel";
            src = builtins.fetchurl {
            url = "https://files.pythonhosted.org/packages/9e/fe/32bd864bcb604b0607924a4cf618ed267a0ef21ac9c3e255109256046e1f/multiprocessing_logging-0.3.4-py2.py3-none-any.whl";
            sha256 = "8a5be02b02edbd6fa6e3e89499af7680db69db9e2d8707fcd28d445fa248f23e";
            };
            propagatedBuildInputs = [ ];
        };

        # Fails to build from nix due to substrait v0.36.0 package
        ibis-framework = pyprev.buildPythonPackage rec {
            pname = "ibis-framework";
            version = "9.5.0";
            format = "wheel";
            src = builtins.fetchurl {
            url = "https://files.pythonhosted.org/packages/dd/a9/899888a3b49ee07856a0bab673652a82ea89999451a51fba4d99e65868f7/ibis_framework-9.5.0-py3-none-any.whl";
            sha256 = "145fe30d94f111cff332580c275ce77725c5ff7086eede93af0b371649d009c0";
            };
            propagatedBuildInputs = [
            prev.python311.pkgs.atpublic
            prev.python311.pkgs.parsy
            prev.python311.pkgs.python-dateutil
            prev.python311.pkgs.pytz
            prev.python311.pkgs.sqlglot
            prev.python311.pkgs.toolz
            prev.python311.pkgs.typing-extensions
            prev.python311.pkgs.duckdb
            prev.python311.pkgs.pyarrow
            prev.python311.pkgs.pyarrow-hotfix
            prev.python311.pkgs.numpy
            prev.python311.pkgs.packaging
            prev.python311.pkgs.pandas
            prev.python311.pkgs.rich
            ];
        };

        };
    };
}
