{ pkgs ? import <nixpkgs> {}
}:

let
  python = import ./requirements.nix { inherit pkgs; };
  version = pkgs.lib.fileContents ./VERSION;
in python.mkDerivation {
  name = "ynab-bank-import-${version}";
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
  outputs = [ "out" "coverage" ];
  buildInputs = with python.packages; [
    # linting
    black
    flake8
    flake8-debugger
    flake8-isort
    flake8-mypy

    # testing
    codecov
    pytest
    pytest-cov

    # debugging
    pdbpp
  ];
  doCheck = true;
  checkPhase = ''
    echo "Running black ..."
    black --check --diff -v setup.py src/
    echo "Running flake8 ..."
    flake8 -v setup.py src/
    echo "Running pytest ..."
    PYTHONPATH=$PWD/src:$PYTHONPATH pytest -v --cov=src/ --tb=native tests/
    cp .coverage $coverage/coverage
  '';
  postInstall = ''
    mkdir -p $coverage/bin $coverage/upload
    cat > $coverage/bin/coverage <<EOL
    #/bin/sh
    cp "$coverage/coverage" ./.coverage
    sed -i -e "s|$PWD/src|\$PWD/src|g" ./.coverage
    eval ${python.packages."codecov"}/bin/codecov
    EOL
    chmod +x $coverage/bin/coverage
  '';
}
