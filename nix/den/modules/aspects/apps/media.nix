{ den, ... }: {
  den.aspects.apps-media = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        spotify simple-scan pdfarranger celluloid
      ];

      programs.mpv = {
        enable = true;
        config = {
          vo = "gpu-next";
          hwdec = "auto-safe";
          gpu-api = "vulkan";
          volume = 80;
          volume-max = 150;
          sub-auto = "fuzzy";
          sub-font-size = 40;
          osd-bar = false;
          osd-font-size = 30;
          save-position-on-quit = true;
          keep-open = true;
        };
      };

      xdg.mimeApps.defaultApplications = {
        "video/mp4" = "io.github.celluloid_player.Celluloid.desktop";
        "video/x-matroska" = "io.github.celluloid_player.Celluloid.desktop";
        "video/webm" = "io.github.celluloid_player.Celluloid.desktop";
        "video/x-msvideo" = "io.github.celluloid_player.Celluloid.desktop";
        "video/quicktime" = "io.github.celluloid_player.Celluloid.desktop";
        "video/x-flv" = "io.github.celluloid_player.Celluloid.desktop";
        "video/ogg" = "io.github.celluloid_player.Celluloid.desktop";
        "video/mpeg" = "io.github.celluloid_player.Celluloid.desktop";
        "video/3gpp" = "io.github.celluloid_player.Celluloid.desktop";
        "video/x-ms-wmv" = "io.github.celluloid_player.Celluloid.desktop";
        "audio/mpeg" = "io.github.celluloid_player.Celluloid.desktop";
        "audio/flac" = "io.github.celluloid_player.Celluloid.desktop";
        "audio/ogg" = "io.github.celluloid_player.Celluloid.desktop";
        "audio/x-wav" = "io.github.celluloid_player.Celluloid.desktop";
        "audio/aac" = "io.github.celluloid_player.Celluloid.desktop";
        "audio/mp4" = "io.github.celluloid_player.Celluloid.desktop";
        "audio/x-ms-wma" = "io.github.celluloid_player.Celluloid.desktop";
        "audio/opus" = "io.github.celluloid_player.Celluloid.desktop";
      };
    };
  };
}
