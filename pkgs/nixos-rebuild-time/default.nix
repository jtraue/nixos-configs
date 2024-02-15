{ writeShellScript
, writers
}:
let
  script = writeShellScript "nixos-rebuild-time.sh" (builtins.readFile ./nixos-rebuild-time.sh);
in
writers.writeBashBin "nixos-rebuild-time" ''
  ${script} "$@"
''
