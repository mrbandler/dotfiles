{ den, ... }: {
  den.aspects.desktop = {
    nixos = { pkgs, lib, ... }: {
      security.polkit.enable = true;

      services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660"
      '';

      environment.systemPackages = with pkgs; [
        xdg-utils xdg-user-dirs
        wayland xwayland wayland-utils wayland-protocols wl-clipboard
      ];

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
      };

      # Fonts
      fonts = {
        packages = with pkgs; [
          inter roboto jetbrains-mono fira-code
          nerd-fonts.jetbrains-mono nerd-fonts.fira-code
          nerd-fonts.meslo-lg nerd-fonts.symbols-only
          symbola noto-fonts-color-emoji noto-fonts-cjk-sans
          corefonts vista-fonts
        ];
        enableDefaultPackages = false;
        fontconfig = {
          enable = true; antialias = true;
          hinting = { enable = true; style = "slight"; };
          subpixel = { rgba = "rgb"; lcdfilter = "default"; };
          defaultFonts = {
            serif = [ "Liberation Serif" "DejaVu Serif" ];
            sansSerif = [ "Inter" "Roboto" "Liberation Sans" "DejaVu Sans" ];
            monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" "Fira Code" ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
      };

      # XDG Portals
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
      };

      # Media
      environment.systemPackages = with pkgs; [ playerctl ];

      # GStreamer
      environment.systemPackages = with pkgs; [
        gst_all_1.gstreamer gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly gst_all_1.gst-libav
        gst_all_1.gst-vaapi
      ];
    };
  };
}
