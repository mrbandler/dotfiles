{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    spacedrive
    cryptomator
    veracrypt
    rclone
    ventoy
  ];
}
