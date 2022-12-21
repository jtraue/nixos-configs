{ writers
, symlinkJoin
, makeWrapper
, writeShellApplication
, pkgs
}:
let
  defaults = rec {
    tftpRoot = "/var/lib/tftp";
    bender = "${tftpRoot}/bootfiles/bender";
    nova = "${tftpRoot}/bootfiles/share/hedron/hypervisor";
    supernovaBinDir = "${tftpRoot}/bootfiles/share/supernova";
    vmm = "${supernovaBinDir}/app/vmm";
    roottask = "${supernovaBinDir}/app/roottaskapp";
    kernel = "${tftpRoot}/bootfiles/bzImage";
    initrd = "${tftpRoot}/bootfiles/initrd";
    sn-args = "--serial --boot=linux --nointrospect";
    qemu-args = "";
    kernel-args = "console=ttyS0 earlyprintk=ttyS0";
  };
  script = builtins.readFile ./qemu-svp.sh;
in
writeShellApplication {
  name = "qemu-svp";
  runtimeInputs = with pkgs; [
    qemu
  ];
  text = with defaults; ''
    export DEFAULT_KERNEL_ARGS=${kernel-args}
    export DEFAULT_BENDER=${bender}
    export DEFAULT_INITRD=${initrd}
    export DEFAULT_KERNEL=${kernel}
    export DEFAULT_NOVA=${nova}
    export DEFAULT_ROOTTASK=${roottask}
    export DEFAULT_VMM=${vmm}
    export DEFAULT_QEMU_ARGS=${qemu-args}
    export DEFAULT_SUPERNOVA_ARGS="${sn-args}"
    export DEFAULT_KERNEL_ARGS=${kernel-args}
    export DEFAULT_GRUB_PATH=${pkgs.grub2}
    ${script} "$@"
  '';
}
