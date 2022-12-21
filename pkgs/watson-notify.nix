{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:
let
  script = ../modules/common/watson/watson-notify.sh;

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
    pkgs.libnotify
    pkgs.coreutils
    pkgs.gnused
  ];
in
pkgs.writeShellScriptBin "watson-notify" ''
  export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
  ${builtins.readFile script}
''
