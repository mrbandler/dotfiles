{
  lib,
  pkgs,
  ...
}:

with lib;
let
  zellij-autolock-wasm = pkgs.fetchurl {
    url = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
    hash = "sha256-aclWB7/ZfgddZ2KkT9vHA6gqPEkJ27vkOVLwIEh7jqQ=";
  };
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "multiplexers" "zellij" ] [ "programs" "zellij" ])
  ];

  config = {
    xdg.configFile = {
      "zellij/plugins/zellij-autolock.wasm".source = zellij-autolock-wasm;
    };

    programs.zellij = {
      enable = true;
      settings = {
        default_shell = "nu";
        # default_layout = "compact";
        show_startup_tips = false;
      };
      extraConfig = ''
        plugins {
            autolock location="file:~/.config/zellij/plugins/zellij-autolock.wasm" {
                is_enabled true
                triggers "nvim|vim|helix|hx|git|fzf|zoxide|atuin|tv|aerc|nano"
                reaction_seconds "0.3"
                print_to_log false
            }
        }

        load_plugins {
            autolock
        }
      '';
    };
  };
}
