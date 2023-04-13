{ stdenv, makeWrapper, onboard }:
stdenv.mkDerivation {
  name = "onboard-keyboard-control";
  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    makeWrapper ${./onboard-keyboard-control.sh} $out/bin/onboard-keyboard-control --prefix PATH : ${onboard}/bin
  '';
}
