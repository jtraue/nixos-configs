{ pkgs, stdenv, lib, fetchurl, ... }:
stdenv.mkDerivation {
  pname = "yass";
  version = "2.4.1";

  src = fetchurl {
    url = "https://yass-along.com/data/downloads/yass-${version}.jar";
    sha = lib.fakeSha256;
  };
}


