{
  lib,
  config,
  namespace,
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
