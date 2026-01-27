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

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self, home-manager, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "x86_64-linux" ];

      imports = [
        inputs.pre-commit-hooks.flakeModule
      ];

      flake =
        let
          nixosModules = import ./modules/nixos;
          homeManagerModules = import ./modules/home-manager;
          hosts = import ./hosts { inherit inputs nixosModules homeManagerModules; };
        in
        {
          inherit nixosModules homeManagerModules;
          inherit (hosts) nixosConfigurations homeConfigurations;
        };

      perSystem = { pkgs, config, system, ... }:
        let
          checkNixosConfigs = builtins.mapAttrs (_: cfg: cfg.config.system.build.toplevel);
          checkHomeConfigs = builtins.mapAttrs (_: cfg: cfg.activationPackage);
        in
        {

          checks =
            (checkNixosConfigs self.nixosConfigurations)
            // (checkHomeConfigs self.homeConfigurations);

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
