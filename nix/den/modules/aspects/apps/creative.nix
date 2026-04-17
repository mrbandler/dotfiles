{ den, ... }: {
  den.aspects.apps-creative = {
    homeManager = { pkgs, ... }: {
      xdg.desktopEntries.material-maker = {
        name = "Material Maker";
        genericName = "Material Editor";
        exec = "material-maker";
        icon = "${pkgs.material-maker}/share/material-maker/examples/mm_icon.png";
        terminal = false;
        categories = [ "Graphics" "3DGraphics" ];
      };

      home.packages = with pkgs; [
        blender blockbench material-maker freecad
        krita graphite inkscape libresprite darktable
        tenacity reaper
        handbrake
        godot_4 unityhub
      ];

      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [ wlrobs ];
      };
    };
  };
}
