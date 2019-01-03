{ pkgs ? import <nixpkgs> {}
}:

let
  python = import ./requirements.nix { inherit pkgs; };
  version = pkgs.lib.fileContents ./VERSION;
in python.mkDerivation {
  name = "pypi2nix-${version}";
  src = pkgs.lib.cleanSourceWith {
    filter = name: type:
      let
        baseName = baseNameOf (toString name);
        name' = builtins.substring (builtins.stringLength (toString ./.))
                                   (builtins.stringLength name)
                                   name;
      in ! (
        (type == "directory" && name' == "__pycache__") ||
        (type == "directory" && name' == "/build") ||
        (type == "directory" && name' == "/src/ynab_bank_import.egg-info")
      );
    src = pkgs.lib.cleanSource ./.;
  };
  buildInputs = with python.packages; [
    flake8
    black
    pytest
    pdbpp
  ];
  doCheck = true;
  checkPhase = ''
    echo "Running black ..."
    black --check --diff -v setup.py src/
    echo "Running flake8 ..."
    flake8 -v setup.py src/
    echo "Running pytest ..."
    PYTHONPATH=$PWD/src:$PYTHONPATH pytest -v --cov=src/ tests/
    cp .coverage $coverage/coverage
  '';
}
