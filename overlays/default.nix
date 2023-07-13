{ pkgs-unstable }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: _prev: {

    # Shared folders are available with 2.4.25 which is not yet stable
    # (https://github.com/abraunegg/onedrive/blob/master/docs/BusinessSharedFolders.md)
    inherit (pkgs-unstable) onedrive;
  };
}
