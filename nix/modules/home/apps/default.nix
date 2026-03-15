{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    jq
    just
    lazygit
    uhk-agent
    spotify
  ];
}
