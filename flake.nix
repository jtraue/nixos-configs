{
  description = "My NixOS configurations";

  inputs = {
    nixvim.url = "git+file:///home/jtraue/conf/nixvim";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      overlays = import ./overlays { };
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      mkPkgs = nixpkgs: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHomeConfig = host: extraArgs: inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs inputs.nixpkgs;
        extraSpecialArgs = {
          inherit homeManagerModules;
          inherit (inputs) nix-colors;
          overlays = builtins.attrValues overlays;
        } // extraArgs;
        modules = [ ./hosts/${host}/home-configuration.nix ];
      };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        inherit nixosModules homeManagerModules overlays;

        nixosConfigurations.x13 = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs nixosModules;
            overlays = builtins.attrValues overlays;
          };
          modules = [
            ./hosts/x13/configuration.nix
            ./hosts/x13/hardware-configuration.nix
          ];
        };

        homeConfigurations = {
          "jtraue@l14" = mkHomeConfig "l14" { };
          "jtraue@x13" = mkHomeConfig "x13" {
            inherit inputs;
            pkgs-unstable = mkPkgs inputs.nixpkgs-unstable;
          };
        };
      };

      systems = [ "x86_64-linux" ];
      imports = [ inputs.pre-commit-hooks.flakeModule ];

      perSystem = { pkgs, config, system, ... }: {
        packages = import ./pkgs { inherit pkgs; };

        devShells.default = pkgs.mkShellNoCC {
          NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
          inputsFrom = [ config.pre-commit.settings.run ];
          buildInputs = with pkgs; [
            nix
            inputs.home-manager.packages.${system}.default
            git
            cachix
          ];
          shellHook = config.pre-commit.installationScript;
        };

        pre-commit = {
          check.enable = true;
          settings.hooks = {
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
}
