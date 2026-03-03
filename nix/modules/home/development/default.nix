{
  lib,
  config,
  namespace,
  ...
}:

with lib;
{
  imports = [
    ./vcs
    ./runtimes
    ./agents
  ];
}
