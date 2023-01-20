# NixOS Configurations

This repository is inspired by https://github.com/Misterio77/nix-starter-configs.

## Bootstrap

I haven't bootstrapped on a new machine - that needs to be covered later on.
I am generally following:
  - <https://nixos.org/manual/nixos/stable/#sec-installation>
  - zimbatm's laptop recommendation in <https://nixos.wiki/wiki/Full_Disk_Encryption>

## Folder structure

- **flake.nix** entry point
- hosts: configurations for individual hosts
  - `configuration.nix` and `hardware-configuration.nix` contain NixOS settings
  - `home-configuration.nix` contains home-manager settings
- modules:
  - nixos: NixOS modules
  - home-manager: home-manager modules
- pkgs: contains custom packages that are not yet managed elsewhere
- overlays: NixOS overlays (includes custom `pkgs` and further modifications of existing packages)

## Usage

The idea is to separate home-manager configuration from NixOS configuration so that this repository ships dotfiles on non NixOS machines. Haven't tried this since flakes migration.

- `nixos-rebuild build --flake .#e14` and `sudo nixos-rebuild switch --flake .#e14`
- `home-manager build --flake .#jtraue@e14` and `home-manager switch --flake .#jtraue@e14`
- `nixos-rebuild build-vm --flake .#e14` for virtual machine
    - Remember to remove `e14.qcow2` for a fresh run.
- inspect size of configuration: `nixos-rebuild build --flake .#e14 && nix shell nixpkgs#nix-tree -c nix-tree ./result
bck-i-search: tree`

## Network boot flow

TFTP folder is at `~/tftp`. It is currently not maintained in any repository.
The NixOS configuration copies ipxe binaries to that folder during activation.
iPXE has an embedded script that tries to fetch files via http on port 8888 at first.
If that fails, it falls back to the TFTP folder.

Helper scripts:

* `tmuxinator testbox`
    * Used for network boot on physical machines
    * Start required tools: dhcp server, meshcommander, minicom
* `qemu-ipxe`
    * Used to experiment with qemu (before switching to a physical machine)
    * Invokes qemu with arguments for network boot
* `sotest-to-ipxe`
    * Converts build outputs for a sotest run to an ipxe configuration and starts a webserver on port 8888
* The nix flake `netboot-experiment` converts a nixos configuration into netboot files.
    1. `nix build .\#netboot-experiment && nix-shell -p python3Packages.python --run 'python3 -m http.server --directory result 8888'`
    2. `qemu-ipxe -m 4096 -b`
