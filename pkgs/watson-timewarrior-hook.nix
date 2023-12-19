{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:
let
  watson-utils = pkgs.fetchFromGitHub {
    owner = "yloiseau";
    repo = "watson-utils";
    rev = "89bf679506cbb49fa8a1ded4347d0f406c25cbf1";
    sha256 = "sha256-lPw6tvENbgZUjxZhx9lPLyaLldj4qba3wIkb5+KisJc=";
  };
  watson-package = pkgs.python3Packages.buildPythonPackage {
    pname = "watson-python";
    inherit (pkgs.watson) version;
    inherit (pkgs.watson) src;
    inherit (pkgs.watson) propagatedBuildInputs;
    doCheck = false;
  };

in
pkgs.writers.writePython3 "watson-taskwarrior-hook"
{
  libraries = [ watson-package ];
  flakeIgnore = [ "E265" "E501" "E202" ];
}
  (builtins.readFile "${watson-utils}/on-modify-watson.py")
