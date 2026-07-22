{
  pkgs,
  ...
}:

{
  imports = [
    ./rclone.nix
  ];

  home.packages = with pkgs; [
    cryptomator
    veracrypt
    ventoy
    ledger-live-desktop
  ];
}
