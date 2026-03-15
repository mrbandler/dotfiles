{ ... }:

{
  internal.desktop.compositor.niri = {
    enable = true;
    settings = {
      outputs = {
        DP-1 = {
          mode = {
            width = 3840;
            height = 1600;
            refresh = 74.977;
          };
          position = {
            x = 0;
            y = 0;
          };
          variable-refresh-rate = true;
        };
        DP-2 = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.000;
          };
          position = {
            x = (3840 - 1920) / 2;
            y = 1600;
          };
          variable-refresh-rate = true;
        };
      };
    };
  };
}
