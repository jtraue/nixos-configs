{ pkgs
}:
{
  onboard-keyboard-control = pkgs.callPackage ./onboard-keyboard-control { };
  screenrotate = pkgs.callPackage ./screenrotate.nix { };
  nixos-rebuild-time = pkgs.callPackage ./nixos-rebuild-time { };
}
