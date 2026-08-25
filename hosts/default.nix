{ inputs, nixosModules, homeManagerModules }:
let
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  mkNixosSystem = { modules, system ? "x86_64-linux" }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system modules;
      specialArgs = { inherit inputs nixosModules; };
    };

  mkHomeConfig = { modules, extraArgs ? { } }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit homeManagerModules inputs; } // extraArgs;
      inherit modules;
    };

  # claude-code moves fast; pull it from nixpkgs-unstable instead of the pinned stable channel
  claudeCodeOverlay = {
    nixpkgs.overlays = [
      (_final: _prev: { inherit (pkgs-unstable) claude-code; })
    ];
  };
in
{
  nixosConfigurations = {
    x13 = mkNixosSystem {
      modules = [
        ./x13/configuration.nix
        ./x13/hardware-configuration.nix
        claudeCodeOverlay
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit homeManagerModules inputs; };
            users.jtraue = import ./x13/home-configuration.nix;
          };
        }
      ];
    };
  };

  homeConfigurations = {
    "jtraue@igor2" = mkHomeConfig {
      modules = [ ./igor2/home-configuration.nix claudeCodeOverlay ];
    };
  };
}
