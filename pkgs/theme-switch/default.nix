{ writeShellScript, writers }:
let
  script = writeShellScript "theme-switch.sh" (builtins.readFile ./theme-switch.sh);
in
writers.writeBashBin "theme-switch" ''
  ${script} "$@"
''
