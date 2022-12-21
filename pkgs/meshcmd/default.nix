{ stdenv
, lib
, fetchurl
, makeWrapper
}:

stdenv.mkDerivation rec {
  name = "meshcmd-${version}";

  version = "0.0.1";

  src = fetchurl {
    name = "meshcmd";
    url = "https://alt.meshcentral.com/meshagents?meshcmd=6&sa=D&sntz=1&usg=AFQjCNHEuyiPIKxeZ1vy8pF2Arj8JxtD3A";
    sha256 = "sha256-6o9drNYch6076J9fMgMz2aK4pQtJFWVV+5e81W8uUOY=";
  };

  phases = [ "installPhase" "fixupPhase" ];

  buildInputs = [ makeWrapper ];

  preFixup = ''
    patchelf \
     --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
     $out/bin/meshcmd
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/meshcmd
    chmod +x $out/bin/meshcmd
    mkdir $out/data
    makeWrapper $out/bin/meshcmd $out/meshcmd --run 'cd $out'
  '';
}
