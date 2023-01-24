{
  common = import ./common.nix;
  desktop = import ./desktop;
  notebook = import ./notebook.nix;
  work = import ./work;
  yubikey = import ./yubikey.nix;
}
