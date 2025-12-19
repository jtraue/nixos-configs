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
  yass = pkgs.callPackage ./yass.nix { };
  ipxe-files = pkgs.callPackage ./ipxe { };
  sotest-to-ipxe = pkgs.callPackage ./sotest-to-ipxe { };
  watson-notify = pkgs.callPackage ./watson-notify { };
  supernote-tool = pkgs.callPackage ./supernote-tool { };
  wsr = pkgs.callPackage ./wsr.nix { };
  nixos-rebuild-time = pkgs.callPackage ./nixos-rebuild-time { };
}
