{
  description = "My NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";


    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , home-manager
    , nixos-hardware
    , nix-colors
    , pre-commit-hooks
    , flake-parts
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; }
      {

        flake = rec {
          nixosModules = import ./modules/nixos;
          homeManagerModules = import ./modules/home-manager;

          # Covers all packages and customizations.
          overlays = import ./overlays { };

          # NixOS configurations
          # Some of them already ship with home-manager configuration.
          nixosConfigurations = {

            e14 = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit inputs nixos-hardware;
                overlays = builtins.attrValues overlays;
              };
              modules = [
                ./hosts/e14/configuration.nix
                ./hosts/e14/hardware-configuration.nix
              ]
              ++ (builtins.attrValues nixosModules);
            };

            l14 = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit nixos-hardware;
                overlays = builtins.attrValues overlays;
              };
              modules = [
                ./hosts/l14/configuration.nix
                ./hosts/l14/hardware-configuration.nix
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
                inherit nixos-hardware;
                overlays = builtins.attrValues overlays;
              };
              modules = [
                ./hosts/vm/configuration.nix
                ./hosts/x13/hardware-configuration.nix # placeholder
                home-manager.nixosModules.home-manager
                {
                  # home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.jtraue = import ./hosts/vm/home-configuration.nix;
                  home-manager.extraSpecialArgs = {
                    inherit homeManagerModules nix-colors;
                    overlays = builtins.attrValues overlays;
                    hostname = "vm";
                  };
                }
              ]
              ++ (builtins.attrValues nixosModules);
            };
          };

          homeConfigurations = {
            # home-manager configurations - intended for non NixOS machines
            "jtraue@l14" = home-manager.lib.homeManagerConfiguration {
              # Workaround for using unfree packages with home-manager
              # (see https://github.com/nix-community/home-manager/issues/2942#issuecomment-1378627909)
              pkgs = import nixpkgs {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
              extraSpecialArgs = {
                inherit homeManagerModules nix-colors;
                overlays = builtins.attrValues overlays;
              };
              modules = [
                ./hosts/l14/home-configuration.nix
              ];
            };
            "jtraue@e14" = home-manager.lib.homeManagerConfiguration {
              # Workaround for using unfree packages with home-manager
              # (see https://github.com/nix-community/home-manager/issues/2942#issuecomment-1378627909)
              pkgs = import nixpkgs {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
              extraSpecialArgs = {
                inherit homeManagerModules nix-colors;
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
              extraSpecialArgs = {
                inherit homeManagerModules nix-colors;
                overlays = builtins.attrValues overlays;
              };
              modules = [
                ./hosts/x13/home-configuration.nix
              ];
            };
          };
        };
        systems = [ "x86_64-linux" ];
        imports = [
          inputs.pre-commit-hooks.flakeModule
          inputs.devshell.flakeModule
        ];
        perSystem = { pkgs, config, system, ... }: {
          # Custom packages that are not yet packaged elsewhere.
          packages =
            import ./pkgs { inherit pkgs; } //
            {

              # Demo package for netboot. Use via:
              # * nix build .\#netboot-experiment && nix-shell -p python3Packages.python --run 'python3 -m http.server --directory result 8888'
              # * qemu-ipxe -m 4096 -b
              netboot-experiment =
                let
                  bootSystem = self.nixosConfigurations.netboot;
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
            };

          devShells.default = pkgs.mkShellNoCC {

            # For onboarding a system that doesn't use flakes yet.
            NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

            inputsFrom = [ config.pre-commit.settings.run ];
            buildInputs = with pkgs; [
              nix
              home-manager.packages."${system}".default
              git
              cachix
            ];
            shellHook = config.pre-commit.installationScript;
          };

          pre-commit = {
            check.enable = true;
            settings = {
              hooks = {
                nixpkgs-fmt.enable = true;
                deadnix.enable = true;
                statix.enable = true;
                shellcheck.enable = false;
              };
              settings.deadnix = {
                noLambdaPatternNames = true;
                noLambdaArg = true;
              };
            };
          };
        };
      };
}
