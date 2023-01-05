{ lib, ipxe, runCommand, writeText, legacy ? false }:
let
  script = writeText "embed.ipxe" ''
    #!ipxe
    dhcp
    chain tftp://''${next-server}/ipxe-default.cfg
  '';

  ipxe-with-extended-multiboot = ipxe.overrideAttrs (oldAttrs: rec {
    patches = [
      # Taken from https://gitlab.vpn.cyberus-technology.de/sotest/sotest/-/tree/master/nix/ipxe for microvm (which uses 9 modules)
      ./0001-multiboot-Increase-module-count-and-cmdline-length.patch
    ];
  });

  ipxe-efi = ipxe-with-extended-multiboot.override {
    # UEFI uses serial console by default and enabling CONSOLE_SERIAL duplicates
    # and messes up all output.
    embedScript = script;
  };

  ipxe-legacy = ipxe-with-extended-multiboot.override {
    # Don't rely on a monitor for remote systems.
    additionalOptions = [
      "CONSOLE_SERIAL"
    ];
    embedScript = script;
  };
in
ipxe-with-extended-multiboot.override {
  # Don't rely on a monitor for remote systems.
  additionalOptions = lib.optionals legacy [
    "CONSOLE_SERIAL"
  ];
  embedScript = script;
}
