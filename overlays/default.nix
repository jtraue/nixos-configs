{ pkgs-unstable }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: prev: {

    # Shared folders are available with 2.4.25 which is not yet stable
    # (https://github.com/abraunegg/onedrive/blob/master/docs/BusinessSharedFolders.md)
    inherit (pkgs-unstable)
      # Shared folders are available with 2.4.25 which is not yet stable
      # (https://github.com/abraunegg/onedrive/blob/master/docs/BusinessSharedFolders.md)
      onedrive

      # Bugfix: https://github.com/NixOS/nixpkgs/pull/246095
      backintime;

    i3status-rust = prev.i3status-rust.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./i3-status-rust-watson-block-without-timetracking.patch
      ];
    });

  };
}
