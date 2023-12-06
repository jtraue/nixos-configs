{}:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: prev: {

    i3status-rust = prev.i3status-rust.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./i3-status-rust-watson-block-without-timetracking.patch
      ];
    });

  };
}
