{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    jq
    just
    lazygit
    sqlite
    sqlitebrowser
    gitnr
    pdftk
  ];
}
