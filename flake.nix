{
  description = "My NixOS configurations";

  inputs = {
    #my-nixvim.url = "/home/jtraue/conf/nixvim";
    my-nixvim.url = "github:jtraue/nixvim/main";
    # my-nixvim.url = "git+ssh://gitea@git.vpn.disturbed.systems/jana/nixvim?ref=modular";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , home-manager
    , pre-commit-hooks
    , flake-parts
    , nixpkgs-unstable
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; }
      {

        flake = rec {
          nixosModules = import ./modules/nixos;
          homeManagerModules = import ./modules/home-manager;

          # NixOS configurations
          # Some of them already ship with home-manager configuration.
          nixosConfigurations = {

            x13 = nixpkgs.lib.nixosSystem
              {
                system = "x86_64-linux";
                specialArgs = {
                  inherit inputs nixosModules;
                };
                modules = [
                  ./hosts/x13/configuration.nix
                  ./hosts/x13/hardware-configuration.nix
                ];
              };


          };

          homeConfigurations = {
            # home-manager configurations - intended for non NixOS machines
            "jtraue@x13" = home-manager.lib.homeManagerConfiguration {
              # Workaround for using unfree packages with home-manager
              # (see https://github.com/nix-community/home-manager/issues/2942#issuecomment-1378627909)
              pkgs = import nixpkgs {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
              extraSpecialArgs = {
                inherit homeManagerModules inputs;
                pkgs-unstable = import nixpkgs-unstable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };

              };
              modules = [
                ./hosts/x13/home-configuration.nix
              ];
            };

            "jtraue@igor2" = home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs {
                system = "x86_64-linux";
              };
              extraSpecialArgs = {
                inherit homeManagerModules inputs;
              };
              modules = [
                ./hosts/igor2/home-configuration.nix
              ];
            };
          };
        };
        systems = [ "x86_64-linux" ];
        imports = [
          inputs.pre-commit-hooks.flakeModule
        ];
        perSystem = { pkgs, config, system, ... }: {

          checks = {
            home-jtraue-x13 = self.homeConfigurations."jtraue@x13".activationPackage;
          };

          devShells.default = pkgs.mkShellNoCC {

            # For onboarding a system that doesn't use flakes yet.
            NIX_CONFIG = "extra-experimental-features = nix-command flakes";

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
                deadnix = {
                  enable = true;
                  settings = {
                    noLambdaPatternNames = true;
                    noLambdaArg = true;
                  };
                };
                statix.enable = true;
                shellcheck.enable = false;
              };
            };
          };
        };
      };
}
