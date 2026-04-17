{ den, ... }:
{
  den.aspects.cli = {
    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        yamlFormat = pkgs.formats.yaml { };
        tomlFormat = pkgs.formats.toml { };
        jsonFormat = pkgs.formats.json { };

        zellij-autolock-wasm = pkgs.fetchurl {
          url = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
          hash = "sha256-aclWB7/ZfgddZ2KkT9vHA6gqPEkJ27vkOVLwIEh7jqQ=";
        };

        colors = config.lib.stylix.colors;
        hexToInt =
          c:
          let
            hexChars = {
              "0" = 0;
              "1" = 1;
              "2" = 2;
              "3" = 3;
              "4" = 4;
              "5" = 5;
              "6" = 6;
              "7" = 7;
              "8" = 8;
              "9" = 9;
              "a" = 10;
              "b" = 11;
              "c" = 12;
              "d" = 13;
              "e" = 14;
              "f" = 15;
              "A" = 10;
              "B" = 11;
              "C" = 12;
              "D" = 13;
              "E" = 14;
              "F" = 15;
            };
            chars = lib.stringToCharacters c;
          in
          lib.foldl' (acc: ch: acc * 16 + hexChars.${ch}) 0 chars;
        channelTo6 =
          v:
          if v < 48 then
            0
          else if v < 115 then
            1
          else
            (v - 35) / 40;
        hexTo256 =
          hex:
          let
            r = hexToInt (builtins.substring 0 2 hex);
            g = hexToInt (builtins.substring 2 2 hex);
            b = hexToInt (builtins.substring 4 2 hex);
          in
          16 + (channelTo6 r) * 36 + (channelTo6 g) * 6 + (channelTo6 b);

        catppuccinThemesSrc = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "posting";
          rev = "main";
          hash = "sha256-xfoyqZ2Jz5of5PxJe6A0icobZNEyMcxBOsES51vPnZs=";
        };
        catppuccinThemes = pkgs.runCommand "catppuccin-posting-themes" { } ''
          mkdir -p $out
          for f in ${catppuccinThemesSrc}/themes/*/*.yaml; do cp "$f" "$out/"; done
        '';

        jrnlSettings = {
          default_hour = 9;
          default_minute = 0;
          editor = "hx";
          encrypt = false;
          highlight = true;
          indent = 2;
          linewrap = 120;
          tagsymbols = "@";
          template = false;
          timeformat = "%F %H:%M";
          journals.default.journal = "~/.local/share/jrnl/journal.txt";
        };
        jrnlConfigFile = yamlFormat.generate "jrnl.yaml" jrnlSettings;

        themeName = lib.mkDefault "catppuccin-mocha";
        flakeDir = "~/.dotfiles/nix";

        nushellCommands = ''
          def "nx rebuild" [] { nh os switch }
          def "nx rb" [] { nx rebuild }
          def "nx build" [] { nh os build }
          def "nx bd" [] { nx build }
          def "nx check" [] { cd ${flakeDir}; nix flake check }
          def "nx ck" [] { nx check }
          def "nx show" [] { cd ${flakeDir}; nix flake show }
          def "nx sw" [] { nx show }
          def "nx update" [] { cd ${flakeDir}; nix flake update }
          def "nx up" [] { nx update }
          def "nx update-input" [input: string] { cd ${flakeDir}; nix flake update $input }
          def "nx ui" [input: string] { nx update-input $input }
          def "nx upgrade" [] { nx update; nx rebuild }
          def "nx ug" [] { nx upgrade }
          def "nx rollback" [] { nh os switch --rollback }
          def "nx rlb" [] { nx rollback }
          def "nx history" [] { sudo nix-env --list-generations --profile /nix/var/nix/profiles/system }
          def "nx hy" [] { nx history }
          def "nx gc" [] { nh clean user }
          def "nx gc-all" [] { nh clean all }
          def "nx gca" [] { nx gc-all }
          def "nx optimize" [] { nix store optimise }
          def "nx opt" [] { nx optimize }
          def "nx search" [query: string] { nh search $query }
          def "nx sr" [query: string] { nx search $query }
          def "nx repl" [] { cd ${flakeDir}; nix repl . }
          def "nx rp" [] { nx repl }
          def nxr [] { nx rebuild }
          def nxb [] { nx build }
          def nxc [] { nx check }
          def nxs [] { nx show }
          def nxu [] { nx update }
          def nxg [] { nx upgrade }
        '';

        bashCommands = ''
          nx() {
            local cmd="$1"; shift 2>/dev/null
            case "$cmd" in
              rebuild|rb)   nh os switch ;; build|bd)     nh os build ;;
              check|ck)     (cd ${flakeDir} && nix flake check) ;;
              show|sw)      (cd ${flakeDir} && nix flake show) ;;
              update|up)    (cd ${flakeDir} && nix flake update) ;;
              update-input|ui) (cd ${flakeDir} && nix flake update "$1") ;;
              upgrade|ug)   nx update && nx rebuild ;;
              rollback|rlb) nh os switch --rollback ;;
              history|hy)   sudo nix-env --list-generations --profile /nix/var/nix/profiles/system ;;
              gc)           nh clean user ;; gc-all|gca)   nh clean all ;;
              optimize|opt) nix store optimise ;; search|sr)    nh search "$1" ;;
              repl|rp)      (cd ${flakeDir} && nix repl .) ;;
              *) echo "nx: unknown command '$cmd'"; return 1 ;;
            esac
          }
          alias nxr='nx rebuild'; alias nxb='nx build'; alias nxc='nx check'
          alias nxs='nx show'; alias nxu='nx update'; alias nxg='nx upgrade'
        '';

        pipelineCommands = ''
          def ed [...args: string] { run-external $env.EDITOR ...$args }
          def find [path?: string] {
            if ($path != null) { tv files $path -p "bat --color=always --style=plain {}" }
            else { tv files -p "bat --color=always --style=plain {}" }
          }
          def search [path?: string] {
            if ($path != null) { tv ripgrep $path } else { tv ripgrep }
          }
          def ports [port?: int] {
            let raw = (ss -tlnp | lines | skip 1 | each { |line|
              let parts = ($line | split row -r '\s+')
              let listen = ($parts | get 3 | default "")
              let idx = ($listen | str index-of ":" -e)
              let addr = if ($idx >= 0) {
                { address: ($listen | str substring 0..($idx - 1) | str trim -l -c '[' | str trim -r -c ']'), port: ($listen | str substring ($idx + 1)..) }
              } else { { address: $listen, port: "" } }
              let proc = ($parts | get 5? | default "" | parse -r 'users:\(\("(?<name>[^"]+)",pid=(?<pid>\d+)' | get 0? | default { name: "-", pid: "-" })
              { proto: ($parts | get 0), address: $addr.address, port: ($addr.port | into int), process: $proc.name, pid: $proc.pid }
            })
            if ($port != null) { $raw | where port == $port } else { $raw | sort-by port }
          }
        '';

        bashPipelines = ''
          ports() {
            if [ -n "$1" ]; then ss -tlnp | awk -v port="$1" 'NR>1 { split($4, a, ":"); p=a[length(a)]; if (p == port) print }'
            else ss -tlnp; fi
          }
        '';
      in
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
          hcloud
          viddy
          yq-go
          doggo
          serpl
          devenv
          ffmpeg-full
          glow
          (harlequin.overridePythonAttrs (old: {
            pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "tomlkit" ];
          }))
          python313Packages.harlequin-postgres
          jrnl
          k9s
          lazydocker
          lazygit
          lazyjj
          nb
          posting
          tailspin
          television
          xh
          zk
        ];

        home.sessionVariables = {
          NB_EDITOR = "hx";
          NB_DEFAULT_EXTENSION = "md";
          NB_AUTO_SYNC = "1";
          NB_HEADER = "2";
          NB_LIMIT = "20";
          NB_COLOR_PRIMARY = toString (hexTo256 colors.base0D);
          NB_COLOR_SECONDARY = toString (hexTo256 colors.base04);
        };

        home.activation.jrnlConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          install -Dm644 ${jrnlConfigFile} $HOME/.config/jrnl/jrnl.yaml
        '';

        xdg.configFile = {
          "glow/glow.yml".source = yamlFormat.generate "glow.yml" {
            style = "auto";
            width = 0;
            pager = true;
            mouse = true;
            showLineNumbers = true;
          };
          "harlequin/config.toml".source = tomlFormat.generate "harlequin.toml" {
            default_profile = "local";
            profiles.local = {
              adapter = "duckdb";
              theme = "catppuccin-mocha";
              limit = 100000;
              keymap_name = [ "vscode" ];
            };
          };
          "k9s/config.yaml".source = yamlFormat.generate "k9s.yaml" {
            k9s = {
              refreshRate = 1;
              ui.enableMouse = true;
            };
          };
          "lazydocker/config.yml".source = yamlFormat.generate "lazydocker.yml" { };
          "lazygit/config.yml".source = yamlFormat.generate "lazygit.yml" {
            gui = {
              showIcons = true;
              nerdFontsVersion = "3";
            };
            git.pagers = [
              {
                command = "diff";
                pager = "delta --paging=never";
              }
              {
                command = "log";
                pager = "bat --style=plain --paging=never";
              }
            ];
          };
          "lazyjj/config.toml".source = tomlFormat.generate "lazyjj.toml" { };
          "posting/config.yaml".source = yamlFormat.generate "posting.yaml" {
            theme = "catppuccin-mocha-blue";
            layout = "vertical";
            animation = "full";
            spacing = "standard";
            pager_json = "bat --language=json --style=plain --paging=always";
            response = {
              prettify_json = true;
              show_size_and_time = true;
            };
            heading = {
              visible = true;
              show_host = true;
              show_version = true;
            };
            url_bar = {
              show_value_preview = true;
              hide_secrets_in_value_preview = true;
            };
            collection_browser = {
              position = "left";
              show_on_startup = true;
            };
            focus = {
              on_startup = "url";
              on_response = "body";
              on_request_open = "url";
            };
            text_input.blinking_cursor = true;
            command_palette.theme_preview = false;
          };
          "tailspin/theme.toml".source = tomlFormat.generate "tailspin.toml" {
            numbers.style = {
              fg = "cyan";
            };
            dates = {
              date = {
                fg = "magenta";
              };
              time = {
                fg = "blue";
              };
              zone = {
                fg = "red";
              };
            };
            urls = {
              http = {
                fg = "red";
              };
              https = {
                fg = "green";
              };
              host = {
                fg = "blue";
              };
              path = {
                fg = "blue";
              };
              query_params_key = {
                fg = "magenta";
              };
              query_params_value = {
                fg = "cyan";
              };
              symbols = {
                fg = "red";
              };
            };
            json.key = {
              fg = "yellow";
            };
          };
          "television".source = ./tv;
          "xh/config.json".source = jsonFormat.generate "xh.json" {
            default_options = [
              "--style=auto"
              "--pretty=all"
            ];
          };
          "zk/config.toml".source = tomlFormat.generate "zk.toml" {
            note = {
              filename = "{{id}}-{{slug title}}";
              extension = "md";
              template = "";
              id-charset = "alphanum";
              id-length = 4;
              id-case = "lower";
            };
            editor.command = "hx";
            format.markdown = {
              link-format = "markdown";
              hashtags = true;
            };
            lsp.diagnostics = {
              wiki-title = "hint";
              dead-link = "error";
            };
            tool = {
              pager = "bat --style=plain";
              fzf-preview = "bat --color=always --style=plain {-1}";
            };
          };
          "zellij/plugins/zellij-autolock.wasm".source = zellij-autolock-wasm;
        };

        xdg.dataFile."posting/themes" = {
          source = catppuccinThemes;
          recursive = true;
        };

        # Shells
        programs.bash = {
          enable = true;
          historyControl = [
            "ignoredups"
            "ignorespace"
          ];
          historySize = 100000;
          historyFileSize = 100000;
          initExtra = bashCommands + bashPipelines;
        };
        programs.nushell = {
          enable = true;
          settings = {
            show_banner = false;
            history = {
              file_format = "sqlite";
              max_size = 100000;
            };
            completions = {
              case_sensitive = false;
              partial = true;
              quick = true;
              algorithm = "fuzzy";
            };
            shell_integration = {
              osc2 = true;
              osc7 = true;
              osc133 = true;
              osc633 = true;
            };
          };
          shellAliases = {
            cat = "bat";
            df = "duf";
            du = "dust";
            lg = "lazygit";
            gs = "git status";
            gd = "git diff";
            gl = "git log --oneline";
            gp = "git pull";
            gcm = "git commit -m";
            ga = "git add";
            zed = "zeditor";
            ff = "fastfetch";
            top = "btop";
            watch = "viddy";
            ld = "lazydocker";
            dk = "docker compose";
            dku = "docker compose up -d";
            dkd = "docker compose down";
            kk = "k9s";
          };
          extraConfig = nushellCommands + pipelineCommands;
        };

        # Prompt
        programs.starship = {
          enable = true;
          enableBashIntegration = true;
          enableNushellIntegration = true;
          presets = [ "nerd-font-symbols" ];
          settings = {
            format = "$shell$all$character";
            os.disabled = true;
            shell = {
              disabled = false;
              format = "$indicator in ";
              bash_indicator = "[bash](bold italic red)";
              nu_indicator = "[nu](bold italic green)";
            };
          };
        };

        # Terminal
        programs.wezterm.extraConfig = ''
          config.window_close_confirmation = 'NeverPrompt'
          config.line_height = 0.9
          config.enable_scroll_bar = false
          config.enable_tab_bar = false
          config.hide_tab_bar_if_only_one_tab = true
          config.window_decorations = 'NONE'
          config.window_padding = { left = '0.5cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }
          config.default_cursor_style = 'BlinkingUnderline'
          config.font = wezterm.font_with_fallback({ 'JetBrainsMono Nerd Font', 'Symbols Nerd Font Mono', 'Symbola' })
          config.adjust_window_size_when_changing_font_size = true
          config.default_prog = {"nu"}
          config.keys = { { key = 'Enter', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment } }
        '';

        # Multiplexers
        programs.tmux = { };
        programs.zellij = {
          enable = true;
          settings = {
            default_shell = "nu";
            show_startup_tips = false;
          };
          extraConfig = ''
            plugins { autolock location="file:~/.config/zellij/plugins/zellij-autolock.wasm" { is_enabled true; triggers "nvim|vim|helix|hx|git|fzf|zoxide|atuin|tv|aerc|nano"; reaction_seconds "0.3"; print_to_log false; } }
            load_plugins { autolock }
          '';
        };

        # Tier 2 tools
        programs.atuin = {
          enable = true;
          enableBashIntegration = true;
          enableNushellIntegration = true;
        };
        programs.bat.enable = true;
        programs.btop = {
          enable = true;
          settings = {
            update_ms = 1000;
            temp_scale = "celsius";
          };
        };
        programs.carapace = {
          enable = true;
          enableBashIntegration = true;
          enableNushellIntegration = true;
        };
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          config = {
            hide_env_diff = true;
            load_dotenv = true;
            warn_timeout = "10s";
            whitelist.prefix = [ (lib.mkDefault "~/dev") ];
          };
        };
        programs.eza = {
          enable = true;
          icons = "auto";
          git = true;
          enableBashIntegration = true;
          enableNushellIntegration = true;
        };
        programs.fastfetch = {
          enable = true;
          settings = {
            logo = {
              source = "nixos";
              padding.top = 1;
            };
            display.separator = " -> ";
            modules = [
              "title"
              "separator"
              {
                type = "os";
                key = "  OS";
              }
              {
                type = "kernel";
                key = "  Kernel";
              }
              {
                type = "host";
                key = "  Host";
              }
              {
                type = "uptime";
                key = "  Uptime";
              }
              {
                type = "packages";
                key = "  Pkgs";
              }
              "break"
              {
                type = "cpu";
                key = "  CPU";
              }
              {
                type = "gpu";
                key = "  GPU";
              }
              {
                type = "memory";
                key = "  RAM";
                percent.type = 0;
              }
              {
                type = "disk";
                key = "  Disk";
                percent.type = 0;
              }
              "break"
              {
                type = "shell";
                key = "  Shell";
              }
              {
                type = "terminal";
                key = "  Term";
              }
              {
                type = "wm";
                key = "  WM";
              }
              {
                type = "command";
                key = "  DE";
                shell = "echo DankMaterialShell";
              }
              {
                type = "terminalfont";
                key = "  Font";
              }
              {
                type = "display";
                key = "  Display";
                compactType = "original-with-refresh-rate";
              }
              "break"
              "colors"
            ];
          };
        };
        programs.fd = {
          enable = true;
          hidden = true;
        };
        programs.fzf = {
          enable = true;
          enableBashIntegration = true;
          defaultCommand = "fd --type f";
        };
        programs.ripgrep = {
          enable = true;
          arguments = [ "--smart-case" ];
        };
        programs.yazi = {
          enable = true;
          enableBashIntegration = true;
          enableNushellIntegration = true;
          shellWrapperName = "y";
        };
        programs.zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableNushellIntegration = true;
        };
        programs.tealdeer = {
          enable = true;
          settings.updates = {
            auto_update = true;
            auto_update_interval_hours = 168;
          };
        };
        programs.nh = {
          enable = true;
          flake = "${config.home.homeDirectory}/.dotfiles/nix";
        };
        programs.aerc = {
          enable = true;
          extraConfig = {
            general.unsafe-accounts-conf = true;
            ui = {
              sidebar-width = 25;
              mouse-enabled = true;
              threading-enabled = true;
              fuzzy-complete = true;
              auto-mark-read = true;
              sort = "-r date";
              index-columns = "date<20,name<20,flags>4,subject<*";
            };
            viewer = {
              pager = "less -R";
              alternatives = "text/plain,text/html";
              header-layout = "From|To,Cc|Bcc,Date,Subject";
              parse-http-links = true;
            };
            compose = {
              header-layout = "To|From,Subject";
              reply-to-self = false;
              empty-subject-warning = true;
              no-attachment-warning = "^[^>]*attach";
            };
            filters = {
              "text/plain" = "colorize";
              "text/html" = "html | colorize";
              "text/calendar" = "calendar";
              "message/delivery-status" = "colorize";
              "message/rfc822" = "colorize";
            };
          };
        };
        programs.himalaya.enable = true;
        programs.khal = {
          enable = true;
          locale = {
            unicode_symbols = true;
            firstweekday = 0;
            weeknumbers = "left";
          };
        };
        programs.vdirsyncer.enable = true;
        services.protonmail-bridge.enable = true;
        services.vdirsyncer = {
          enable = true;
          frequency = "*:0/1";
        };
      };
  };
}
