{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  harpoon-wasm = pkgs.fetchurl {
    url = "https://github.com/Nacho114/harpoon/releases/download/v0.3.0/harpoon.wasm";
    hash = "sha256-f4z1enHx27vRFTN6MWOHgNfhjpuHbe8cgclwGIyqMvI=";
  };
  zellij-forgot-wasm = pkgs.fetchurl {
    url = "https://github.com/karimould/zellij-forgot/releases/download/0.4.2/zellij_forgot.wasm";
    hash = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds=";
  };
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
      "zellij/plugins/harpoon.wasm".source = harpoon-wasm;
      "zellij/plugins/zellij_forgot.wasm".source = zellij-forgot-wasm;
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
        keybinds {
            shared_except "locked" {
                bind "Ctrl Tab" {
                    LaunchOrFocusPlugin "file:~/.config/zellij/plugins/harpoon.wasm" {
                        floating true
                        move_to_focused_tab true
                    }
                }
                bind "Ctrl Shift /" {
                    LaunchOrFocusPlugin "file:~/.config/zellij/plugins/zellij_forgot.wasm" {
                        "LOAD_ZELLIJ_BINDINGS" "true"
                        floating true
                    }
                }
            }
        }

        plugins {
            autolock location="file:~/.config/zellij/plugins/zellij-autolock.wasm" {
                is_enabled true
                triggers "nvim|vim|helix|hx|git|fzf|zoxide|atuin|tv"
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
