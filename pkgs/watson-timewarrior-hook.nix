{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:
let
  sources = import ../nix/sources.nix;
  watson-python = pkgs.python3Packages.buildPythonPackage {
    pname = "watson-python";
    inherit (pkgs.watson) version;
    inherit (pkgs.watson) src;
    inherit (pkgs.watson) propagatedBuildInputs;
    doCheck = false;
  };

  runtimeInputs = [
    (pkgs.python3.withPackages (_ps: [
      watson-python
    ]))
  ];

in
pkgs.writeShellScriptBin "watson-timewarrior-hook" ''
  export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
  python ${sources.watson-utils}/on-modify-watson.py
''
