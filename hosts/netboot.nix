{ pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];

  networking.hostName = "netboot";

  system.stateVersion = "22.11";
}
