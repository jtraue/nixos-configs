{ lib, ipxe, runCommand, writeText }:
let
  script = writeText "embed.ipxe" ''
    #!ipxe
    dhcp
    # If a temporary webserver exists, use that.
    # Try the machine specific configuration otherwise and fall back
    # to a generic configuration if that one does not exist.
    chain http://''${next-server}:8888/ipxe-default.cfg || chain tftp://''${next-server}/ipxe-default.cfg || shell
  '';

  ipxe-with-extended-multiboot = ipxe.overrideAttrs (oldAttrs: rec {
    patches = [
      # The number of multiboot modules and the command line length are limited
      # in iPXE and it does not notify anyone if they are exceeded :/
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
runCommand "ipxe-files" { } ''
  mkdir -p $out
  cp  ${ipxe-efi}/ipxe.efi $out/
  cp  ${ipxe-legacy}/undionly.kpxe $out/ipxe.kpxe
''
