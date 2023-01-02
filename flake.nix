{
  description = "My NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    # Meshcommander is broken since commit 07b207c5e9a47b640fe30861c9eedf419c38dce0
    # Did not yet debug further - something in the nodejs build changed.
    nixpkgs-meshcommander.url = "github:nixos/nixpkgs?rev=7030b3d11c05cbaa31429e1a6dc9eed156591c47";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, nixpkgs-meshcommander, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSupportedSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    rec {
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      # Custom packages that are not yet packaged elsewhere.
      packages = forAllSupportedSystems (system:
        import ./pkgs {
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      # Covers all packages and customizations.
      overlays = import ./overlays;

      # NixOS configurations
      # Some of them already ship with home-manager configuration.
      nixosConfigurations = {

        e14 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit overlays nixos-hardware nixpkgs-meshcommander; };
          modules = [
            ./hosts/e14/configuration.nix
            ./hosts/e14/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jtraue = import ./hosts/e14/home-configuration.nix;
              home-manager.extraSpecialArgs = {
                inherit homeManagerModules;
                hostname = "e14";
              };
            }
          ]
          ++ (builtins.attrValues nixosModules);
        };

        x13 = nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            specialArgs = {
              inherit overlays nixosModules nixos-hardware;
            };
            modules = [
              ./hosts/x13/configuration.nix
              ./hosts/x13/hardware-configuration.nix
            ];
          };
      };

      # home-manager configurations - intended for non NixOS machines
      homeConfigurations = {
        "jtraue@x13" = home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit homeManagerModules overlays; };
          modules = [
            ./hosts/x13/home-configuration.nix
          ];
        };
      };

      devShells = forAllSupportedSystems
        (system: {
          default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
        });
    };
}
