{ pkgs, stdenv, lib, fetchurl, jre, makeWrapper, ... }:
stdenv.mkDerivation rec {
  pname = "yass";
  version = "2.4.1";

  src = fetchurl {
    url = "https://yass-along.com/data/downloads/yass-${version}.jar";
    sha256 = "sha256-b/ufsrwWkbxGttXmz31CArnIKv/WNFDklzW8zzdeGMg=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    makeWrapper ${jre}/bin/java $out/bin/yass \
      --prefix PATH : ${lib.makeBinPath [jre]} \
      --add-flags "-jar ${src}"

    runHook postInstall
    '';
}


