{ config, lib, ... }:

let
  cfg = config.nixos-modules.desktop.autorandr;
  home = "00ffffffffffff0010ac31a14c474530101e0104b55021783eee95a3544c99260f5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a0295030203a00204f3100001a000000ff0048584c343654320a2020202020000000fc0044454c4c205533343139570a20000000fd0030551e5920010a202020202020018902031df1509005040302071601141f1213454b4c5a2309070783010000023a801871382d40582c4500204f3100001e584d00b8a1381440942cb500204f3100001e565e00a0a0a0295030203500204f3100001a3c41b8a060a029505020ca04204f3100001a0000000000000000000000000000000000000000000000000000d5";
  x13-internal = "00ffffffffffff0010ac32a14c474530101e0104b55021783eee95a3544c99260f5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a0295030203a00204f3100001a000000ff0048584c343654320a2020202020000000fc0044454c4c205533343139570a20000000fd0030551e5920010a202020202020018802031df1509005040302071601141f1213454b4c5a2309070783010000023a801871382d40582c4500204f3100001e584d00b8a1381440942cb500204f3100001e565e00a0a0a0295030203500204f3100001a3c41b8a060a029505020ca04204f3100001a0000000000000000000000000000000000000000000000000000d5";
  e14-notebook = "00ffffffffffff000dae0a1400000000291d0104a51f11780328659759548e271e505400000001010101010101010101010101010101363680a0703820403020a60035ad10000018000000fe004e3134304843412d4541450a20000000fe00434d4e0a202020202020202020000000fe004e3134304843412d4541450a200002";

  office =
    "00ffffffffffff001e6d085b71480100011c0103803c2278ea3035a7554ea3260f50542108007140818081c0a9c0d1c081000101010104740030f2705a80b0588a0058542100001e565e00a0a0a029503020350058542100001a000000fd00383d1e871e000a202020202020000000fc004c4720556c7472612048440a2001d002031d7146902205040301230907076d030c002000b83c200060010203023a801871382d40582c450058542100001e000000ff003830314e54545132473038310a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f";
in
{

  options.nixos-modules.desktop.autorandr = {
    enable = lib.mkEnableOption "Enables autorandr.";
  };

  config = lib.mkIf cfg.enable {

    services.autorandr = {
      enable = true;

      profiles = {
        "home-x13" = {
          fingerprint = {
            DP-2-1-6 = home;
            eDP-1 = x13-internal;
          };
          config = {
            DP-2-1-6 = {
              enable = true;
              mode = "3440x1440";
              position = "1920x0";
              rate = "59.91";
              primary = true;
            };
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              rate = "60.00";
            };
          };
        };
        "mobile-x13" = {
          fingerprint = {
            eDP-1 = x13-internal;
          };
          config = {
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              primary = true;
              rate = "60.00";
            };
          };
        };
      };
      profiles = {
        "home-e14" = {
          fingerprint = {
            DP-2-1-6 = home;
            eDP-1 = e14-notebook;
          };
          config = {
            DP-2-1-6 = {
              enable = true;
              mode = "3440x1440";
              position = "1920x0";
              rate = "59.91";
              primary = true;
            };
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              rate = "60.00";
            };
          };
        };
        "homePbP-e14" = {
          fingerprint = {
            DP-2-1-6 = "00ffffffffffff0010ac32a14c474530101e0104b52821783eee95a3544c99260f5054a54b00714f81008180a940d1c00101010101013c41b8a060a029505020ca04904f1100001a000000ff0048584c343654320a2020202020000000fc0044454c4c205533343139570a20000000fd0030551e5920010a20202020202001ba02031df1509005040302071601141f1213454b4c5a2309070783010000023a801871382d40582c4500904f1100001e584d00b8a1381440942cb500904f1100001e565e00a0a0a0295030203500904f1100001ae77c70a0d0a0295030203a00904f1100001a00000000000000000000000000000000000000000000000000003b";
            eDP-1 = "00ffffffffffff0006af2d5b00000000001c0104a51d107803ee95a3544c99260f505400000001010101010101010101010101010101b43780a070383e403a2a350025a21000001a902c80a070383e403a2a350025a21000001a000000fe003036564736814231333348414e0000000000024122a8011100000a010a202000f0";
          };
          config = {
            DP-2-1-6 = {
              enable = true;
              mode = "1720x1440";
              position = "1920x0";
              primary = true;
              rate = "59.91";
            };
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              rate = "60.00";
            };
          };
        };
        "mobile-e14" = {
          fingerprint = {
            eDP-1 = e14-notebook;
          };
          config = {
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              primary = true;
              rate = "60.00";
            };
          };
        };
        "office" = {
          fingerprint = {
            HDMI-1 = office;
            eDP-1 = e14-notebook;
          };
          config = {
            HDMI-1 = {
              enable = true;
              mode = "2560x1440";
              position = "1920x0";
              rate = "59.95";
              primary = true;
            };
            eDP-1 = {
              enable = true;
              mode = "1920x1080";
              position = "0x0";
              rate = "60.00";
            };
          };
        };
      };
    };
  };
}
