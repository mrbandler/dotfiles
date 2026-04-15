{
  pkgs,
  ...
}:

{
  imports = [
    ./obs.nix
  ];

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
