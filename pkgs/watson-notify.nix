{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:
let
  script = ../modules/common/watson/watson-notify.sh;

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
    pkgs.libnotify
    pkgs.coreutils
    pkgs.gnused
  ];
in
pkgs.writeShellScriptBin "watson-notify" ''
  export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
  ${builtins.readFile script}
''
