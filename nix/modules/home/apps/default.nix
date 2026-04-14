{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    claude-desktop
    loupe
    file-roller
    gparted
  ];

  # Register Loupe as default image viewer
  xdg.mimeApps.defaultApplications = let
    viewer = "org.gnome.Loupe.desktop";
  in {
    "image/png" = viewer;
    "image/jpeg" = viewer;
    "image/gif" = viewer;
    "image/webp" = viewer;
    "image/svg+xml" = viewer;
    "image/bmp" = viewer;
    "image/tiff" = viewer;
    "image/avif" = viewer;
    "image/jxl" = viewer;
  };
}
