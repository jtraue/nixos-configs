{ pkgs
}:
{
  onboard-keyboard-control = pkgs.callPackage ./onboard-keyboard-control { };
  screenrotate = pkgs.callPackage ./screenrotate.nix { };
  supernote-tool = pkgs.callPackage ./supernote-tool { };
  nixos-rebuild-time = pkgs.callPackage ./nixos-rebuild-time { };
}
