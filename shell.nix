{ pkgs
, checks
, system
}: pkgs.mkShell {
  inherit (checks.${system}.pre-commit-check) shellHook;
  NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    git
  ];
}
