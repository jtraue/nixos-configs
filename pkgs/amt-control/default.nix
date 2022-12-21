{ lib
, writeShellScriptBin
, amtterm
, wsmancli
}:
let
  runtimeInputs = [
    wsmancli
    amtterm
  ];
in
writeShellScriptBin "amt-control" ''
  export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
  ${builtins.readFile ./amt-control.sh}
''
