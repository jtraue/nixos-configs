{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:
let
  sources = import ../nix/sources.nix;
  watson-python = pkgs.python3Packages.buildPythonPackage {
    pname = "watson-python";
    version = pkgs.watson.version;
    src = pkgs.watson.src;
    propagatedBuildInputs = pkgs.watson.propagatedBuildInputs;
    doCheck = false;
  };

  runtimeInputs = [
    (pkgs.python3.withPackages (ps: [
      watson-python
    ]))
  ];

in
pkgs.writeShellScriptBin "watson-timewarrior-hook" ''
  export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
  python ${sources.watson-utils}/on-modify-watson.py
''
