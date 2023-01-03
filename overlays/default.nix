{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {

    # Print ipxe output to serial as well (handy when using headless qemu).
    ipxe = (prev.ipxe.overrideAttrs (oldAttrs: rec {
      patches = [
        # Taken from https://gitlab.vpn.cyberus-technology.de/sotest/sotest/-/tree/master/nix/ipxe for microvm (which uses 9 modules)
        ./ipxe/0001-multiboot-Increase-module-count-and-cmdline-length.patch
      ];
    })).override {
      additionalOptions = [
        "CONSOLE_SERIAL"
      ];
      embedScript = ./ipxe/ipxe-default.cfg;
    };

  };
}
