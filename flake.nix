{
  description = "My NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";

    # Meshcommander is broken since commit 07b207c5e9a47b640fe30861c9eedf419c38dce0
    # Did not yet debug further - something in the nodejs build changed.
    nixpkgs-meshcommander.url = "github:nixos/nixpkgs?rev=7030b3d11c05cbaa31429e1a6dc9eed156591c47";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    { nixpkgs
    , home-manager
    , nixos-hardware
    , nixpkgs-meshcommander
    , nixpkgs-unstable
    , nix-colors
    , pre-commit-hooks
    , ...
    }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSupportedSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    rec {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      # Custom packages that are not yet packaged elsewhere.
      packages = forAllSupportedSystems
        (system:
          import ./pkgs
            {
              pkgs = nixpkgs.legacyPackages.${system};
            } // {

            # Demo package for netboot. Use via:
            # * nix build .\#netboot-experiment && nix-shell -p python3Packages.python --run 'python3 -m http.server --directory result 8888'
            # * qemu-ipxe -m 4096 -b
            netboot-experiment =
              let
                bootSystem = nixosConfigurations.netboot;
                inherit (bootSystem.config.system) build;
                # Pass `cmdline` variable to NixOS ipxe script.
                ipxe-script = nixpkgs.legacyPackages.x86_64-linux.writeText "ipxe-default.cfg" ''
                  #!ipxe
                  set cmdline earlyprintk=serial,ttyS0,115200n8,keep console=ttyS0 loglevel=7
                  chain http://''${next-server}:8888/netboot.ipxe
                '';
              in
              nixpkgs.legacyPackages.x86_64-linux.runCommand "netboot-files" { } ''
                mkdir -p $out
                ln -s ${build.netbootRamdisk}/initrd $out/initrd
                ln -s ${build.kernel}/bzImage $out/bzImage
                ln -s ${ipxe-script} $out/ipxe-default.cfg
                ln -s ${build.netbootIpxeScript}/netboot.ipxe $out/netboot.ipxe
              '';
          }
        );

      # Covers all packages and customizations.
      overlays = import ./overlays;

      # NixOS configurations
      # Some of them already ship with home-manager configuration.
      nixosConfigurations = {

        e14 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit nixos-hardware nixpkgs-meshcommander;
            overlays = builtins.attrValues overlays;
          };
          modules = [
            ./hosts/e14/configuration.nix
            ./hosts/e14/hardware-configuration.nix
          ]
          ++ (builtins.attrValues nixosModules);
        };

        x13 = nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            specialArgs = {
              inherit nixosModules nixos-hardware;
              overlays = builtins.attrValues overlays;
            };
            modules = [
              ./hosts/x13/configuration.nix
              ./hosts/x13/hardware-configuration.nix
            ];
          };

        netboot = nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            specialArgs = {
              inherit nixosModules nixos-hardware;
              overlays = builtins.attrValues overlays;
            };
            modules = [
              ./hosts/netboot.nix
            ];
          };

        vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit nixos-hardware nixpkgs-meshcommander;
            overlays = builtins.attrValues overlays;
          };
          modules = [
            ./hosts/vm/configuration.nix
            home-manager.nixosModules.home-manager
            {
              # home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jtraue = import ./hosts/vm/home-configuration.nix;
              home-manager.extraSpecialArgs =
                let
                  pkgs-unstable = import nixpkgs-unstable {
                    system = "x86_64-linux";
                    config.allowUnfree = true;
                  };
                in
                {
                  inherit homeManagerModules pkgs-unstable nix-colors;
                  overlays = builtins.attrValues overlays;
                  hostname = "vm";
                };
            }
          ]
          ++ (builtins.attrValues nixosModules);
        };
      };

      # home-manager configurations - intended for non NixOS machines
      homeConfigurations = {
        "jtraue@e14" = home-manager.lib.homeManagerConfiguration {
          # Workaround for using unfree packages with home-manager
          # (see https://github.com/nix-community/home-manager/issues/2942#issuecomment-1378627909)
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs =
            let
              pkgs-unstable = import nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            in
            {
              inherit homeManagerModules pkgs-unstable nix-colors;
              overlays = builtins.attrValues overlays;
            };
          modules = [
            ./hosts/e14/home-configuration.nix
          ];
        };
        "jtraue@x13" = home-manager.lib.homeManagerConfiguration {
          # Workaround for using unfree packages with home-manager
          # (see https://github.com/nix-community/home-manager/issues/2942#issuecomment-1378627909)
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs =
            let
              pkgs-unstable = import nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            in
            {
              inherit homeManagerModules pkgs-unstable nix-colors;
              overlays = builtins.attrValues overlays;
            };
          modules = [
            ./hosts/x13/home-configuration.nix
          ];
        };
      };

      devShells = forAllSupportedSystems
        (system: {
          default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix {
            inherit system checks;
          };
        });

      checks = forAllSupportedSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            shellcheck.enable = true;
          };
        };
      });
    };
}
