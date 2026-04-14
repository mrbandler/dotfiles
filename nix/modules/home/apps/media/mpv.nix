{
  lib,
  pkgs,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "media" "mpv" ] [ "programs" "mpv" ])
  ];

  config = {
    programs.mpv = {
      enable = true;
      config = {
        # Video
        vo = "gpu-next";
        hwdec = "auto-safe";
        gpu-api = "vulkan";

        # Audio
        volume = 80;
        volume-max = 150;

        # Subtitles
        sub-auto = "fuzzy";
        sub-font-size = 40;

        # OSD
        osd-bar = false;
        osd-font-size = 30;

        # Misc
        save-position-on-quit = true;
        keep-open = true;
      };
    };

    home.packages = [ pkgs.celluloid ];

    # Register Celluloid as default for media file types
    xdg.mimeApps.defaultApplications = let
      celluloid = "io.github.celluloid_player.Celluloid.desktop";
    in {
      # Video
      "video/mp4" = celluloid;
      "video/x-matroska" = celluloid;
      "video/webm" = celluloid;
      "video/x-msvideo" = celluloid;
      "video/quicktime" = celluloid;
      "video/x-flv" = celluloid;
      "video/ogg" = celluloid;
      "video/mpeg" = celluloid;
      "video/3gpp" = celluloid;
      "video/x-ms-wmv" = celluloid;

      # Audio
      "audio/mpeg" = celluloid;
      "audio/flac" = celluloid;
      "audio/ogg" = celluloid;
      "audio/x-wav" = celluloid;
      "audio/aac" = celluloid;
      "audio/mp4" = celluloid;
      "audio/x-ms-wma" = celluloid;
      "audio/opus" = celluloid;
    };
  };
}
