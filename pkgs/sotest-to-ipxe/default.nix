{ writeShellApplication, yq, python3Packages }:
writeShellApplication {
  name = "sotest-to-ipxe";
  text = builtins.readFile ./sotest-to-ipxe.sh;
  runtimeInputs = [ yq python3Packages.python ];
}
