{
  lib,
  config,
  ...
}:

with lib;
{
  imports = [
    ./vscode.nix
    ./helix.nix
    ./zed.nix
  ];
}
