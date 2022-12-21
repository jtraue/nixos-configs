{ writeShellScript
, writers
, OVMF
}:
let
  script = writeShellScript "qemu-ipxe.sh" (builtins.readFile ./qemu-ipxe.sh);
in
writers.writeBashBin "qemu-ipxe" ''
  export OVMF_FOLDER=${OVMF.fd}/FV
  ${script} "$@"
''
