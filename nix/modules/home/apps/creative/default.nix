{
  pkgs,
  ...
}:

{
  imports = [
    ./obs.nix
  ];

  # Material Maker has no desktop entry — create one
  xdg.desktopEntries.material-maker = {
    name = "Material Maker";
    genericName = "Material Editor";
    exec = "material-maker";
    icon = "${pkgs.material-maker}/share/material-maker/examples/mm_icon.png";
    terminal = false;
    categories = [ "Graphics" "3DGraphics" ];
  };

  home.packages = with pkgs; [
    # 3D / CAD
    blender
    blockbench
    material-maker
    freecad

    # 2D
    krita
    graphite
    inkscape
    libresprite
    darktable

    # Audio
    tenacity
    reaper

    # Video
    handbrake

    # Game engines
    godot_4
    unityhub
  ];
}
