# Pin zellij to stable — 0.44.0 silently ignores external theme files (zellij-org/zellij#4909)
{ inputs, ... }:

final: _prev: {
  zellij = inputs.nixpkgs-stable.legacyPackages.${final.system}.zellij;
}
