{ inputs, ... }:

final: _prev: {
  claude-desktop = inputs.claude-desktop.packages.${final.system}.claude-desktop;
}
