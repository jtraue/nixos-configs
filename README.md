# NixOS Configuration

Personal NixOS configuration using Nix flakes. 
Manages system configurations for multiple hosts with home-manager for dotfiles. 

## Structure

```
.
├── flake.nix              # Main entry point
├── hosts/                 # Per-machine configurations
│   ├── igor2/             # Home-manager only
│   └── x13/               # ThinkPad X13 Yoga (GNOME)
└── modules/
    ├── nixos/             # NixOS modules (my.common, my.desktop)
    └── home-manager/      # Home-manager modules (my.common, my.desktop)
```

## Usage

### Building and Switching

```bash
# Build NixOS configuration
nixos-rebuild build --flake .#x13

# Switch to new NixOS configuration
sudo nixos-rebuild switch --flake .#x13

# Build home-manager configuration
home-manager build --flake .#jtraue@x13

# Switch to new home-manager configuration
home-manager switch --flake .#jtraue@x13
```

### Development

```bash
# Enter development shell with pre-commit hooks
nix develop

# Run checks (formatting, linting, dead code detection)
nix flake check

# Show all flake outputs
nix flake show

# Analyze configuration size
nixos-rebuild build --flake .#x13 && nix shell nixpkgs#nix-tree -c nix-tree ./result
```
