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
in
{
  nixosConfigurations = {
    x13 = mkNixosSystem {
      modules = [
        ./x13/configuration.nix
        ./x13/hardware-configuration.nix
      ];
    };
  };

  homeConfigurations = {
    "jtraue@x13" = mkHomeConfig {
      modules = [ ./x13/home-configuration.nix ];
      extraArgs = { inherit pkgs-unstable; };
    };

    "jtraue@igor2" = mkHomeConfig {
      modules = [ ./igor2/home-configuration.nix ];
    };
  };
}
