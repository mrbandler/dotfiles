{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    jq
    just
    jnv
    kmon
    process-compose
    gitnr
    pdftk
  ];
}
