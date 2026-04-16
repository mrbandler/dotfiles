{
  pkgs,
  ...
}:

{
  imports = [
    ./rclone.nix
  ];

  home.packages = with pkgs; [
    spacedrive
    cryptomator
    veracrypt
    ventoy
  ];
}
