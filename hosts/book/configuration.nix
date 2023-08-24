{ _ }:
{
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;

  nixos-modules.common.enable = true;
  nixos-modules.desktop.enable = true;

  networking = {
    hostName = "book";
  };

  services.xserver.xrandrHeads = [
    "DSI-1"
    {
      monitorConfig = ''
        Option "Rotate" "right"
      '';
      output = "DSI-1";
    }
  ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  system.stateVersion = "21.05";
}
