{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.internal.desktop.fileManagers.nautilus;
in
{
  options.internal.desktop.fileManagers.nautilus = {
    enable = mkEnableOption "Nautilus file manager";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nautilus ];

    dconf.settings = {
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        show-hidden-files = true;
      };

      "org/gnome/nautilus/list-view" = {
        default-zoom-level = "small";
        use-tree-view = true;
      };
    };
  };
}
