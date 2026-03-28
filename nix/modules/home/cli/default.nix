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
    duf
    dust
    ncdu
    ouch
    process-compose
    sd
    tokei
    trashy
    gitnr
    pdftk
    hyperfine
    watchexec
    vhs
    static-web-server
    proton-vpn-cli
  ];
}
