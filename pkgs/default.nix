{ pkgs
}:
{
  amt-control = pkgs.callPackage ./amt-control { };
  amtterm = pkgs.callPackage ./amtterm { };
  meshcmd = pkgs.callPackage ./meshcmd { };
  onboard-keyboard-control = pkgs.callPackage ./onboard-keyboard-control { };
  qemu-ipxe = pkgs.callPackage ./qemu-ipxe { };
  qemu-svp = pkgs.callPackage ./qemu-svp { };
  screenrotate = pkgs.callPackage ./screenrotate.nix { };
  theme-switch = pkgs.callPackage ./theme-switch { };
  yass = pkgs.callPackage ./yass.nix { };
}
