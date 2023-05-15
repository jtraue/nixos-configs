{ fetchFromGitHub
, python3
}:
let
  pypotrace = python3.pkgs.buildPythonPackage rec {
    pname = "pypotrace";
    version = "0.0.1";
    src = fetchFromGitHub {
      owner = "tatarize";
      repo = "potrace";
      rev = "4a279373a86050554c32e1eb71a1e2aa2689f251";
      sha256 = "sha256-RCkA1rvv/4t/56Z7kJeEZGvPG1+SlSIuIaop6qWtYnU=";

    };
    projectDir = src;


    # This was tedious to get to build right. The buildInputs/nativeBuildInputs have been
    # cargo-culted to allow the build to succeed. At some point this could probably
    # be made a lot smaller
    nativeBuildInputs = [
      # pkgs.agg
      # pkgs.python3Packages.pkgconfig
      # pkgs.python3Packages.cython
      # pkgs.potrace
      python3.pkgs.numpy
      # pkgs.pkg-config
    ];
    buildInputs = [
      # pkgs.agg
      # pkgs.python3Packages.pkgconfig
      # pkgs.python3Packages.cython
      # pkgs.potrace
      python3.pkgs.numpy
    ];

    doCheck = false;
  };
in
python3.pkgs.buildPythonApplication rec {
  pname = "supernote-tool";
  version = "0.4.2";
  format = "pyproject";

  src = fetchFromGitHub
    {
      owner = "jya-dev";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-uQY5XPMkQHepF96OZ11WxMUt/ie568+/buUFa9AbCMk=";
    };

  propagatedBuildInputs = with python3.pkgs; [
    colour
    fusepy
    hatchling
    pypng
    pypotrace
    reportlab
    svgwrite
    numpy
    svglib
  ];

}
