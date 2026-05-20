{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  profile = config.home.username;
in
{
  imports = [
    (mkAliasOptionModule [ "internal" "apps" "web" "zen" ] [ "programs" "zen-browser" ])
  ];

  config = {
    # Workaround for custom profiles issue: https://github.com/0xc000022070/zen-browser-flake/issues/179
    home.sessionVariables.MOZ_LEGACY_PROFILES = "1";
    stylix.targets.zen-browser.profileNames = [ profile ];

    # Zen Beta ignores XDG and creates ~/.zen/ on launch — remove it on rebuild
    home.activation.cleanZenLegacyDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -rf "$HOME/.zen"
    '';

    # Seed zen-sessions.jsonlz4 on fresh profiles so the flake's workspace writer
    # doesn't skip activation (upstream bug: it exits early if the file doesn't exist)
    home.activation.zenSessionsSeed =
      lib.hm.dag.entryBetween [ "zen-sessions-${profile}" ] [ "writeBoundary" ]
        ''
          SESSIONS_FILE="${config.xdg.configHome}/zen/${profile}/zen-sessions.jsonlz4"
          if [ ! -f "$SESSIONS_FILE" ]; then
            SEED_TMP="$(mktemp)"
            echo '{"spaces":[],"tabs":[],"folders":[],"groups":[],"lastSelected":0,"splitViewData":{"groups":[]}}' > "$SEED_TMP"
            ${lib.getExe pkgs.mozlz4a} "$SEED_TMP" "$SESSIONS_FILE"
            rm -f "$SEED_TMP"
            echo "zen-sessions: Seeded empty sessions file for fresh profile"
          fi
        '';

    # Sort workspaces by position after the flake's writer runs
    # (upstream bug: spaces are inserted in alphabetical order, not by position)
    home.activation.zenSessionsSort = lib.hm.dag.entryAfter [ "zen-sessions-${profile}" ] ''
      SESSIONS_FILE="${config.xdg.configHome}/zen/${profile}/zen-sessions.jsonlz4"
      if [ -f "$SESSIONS_FILE" ]; then
        SORT_TMP="$(mktemp)"
        SORT_OUT="$(mktemp)"
        ${lib.getExe pkgs.mozlz4a} -d "$SESSIONS_FILE" "$SORT_TMP" 2>/dev/null
        ${lib.getExe pkgs.jq} '.spaces = (.spaces | sort_by(.position))' "$SORT_TMP" > "$SORT_OUT" 2>/dev/null
        if [ -s "$SORT_OUT" ]; then
          ${lib.getExe pkgs.mozlz4a} "$SORT_OUT" "$SESSIONS_FILE"
          echo "zen-sessions: Sorted workspaces by position"
        fi
        rm -f "$SORT_TMP" "$SORT_OUT"
      fi
    '';

    # Set Zen as default browser for XDG MIME handlers
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "zen-beta.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/about" = "zen-beta.desktop";
        "x-scheme-handler/unknown" = "zen-beta.desktop";
        "application/xhtml+xml" = "zen-beta.desktop";
        "application/x-extension-htm" = "zen-beta.desktop";
        "application/x-extension-html" = "zen-beta.desktop";
        "application/x-extension-shtml" = "zen-beta.desktop";
        "application/x-extension-xhtml" = "zen-beta.desktop";
        "application/x-extension-xht" = "zen-beta.desktop";
      };
    };

    # Separate desktop entry for private browsing
    xdg.desktopEntries.zen-beta-private = {
      name = "Zen (Private)";
      genericName = "Private Web Browser";
      exec = "zen-beta --profile ${config.xdg.configHome}/zen/${profile} --private-window %U";
      icon = "zen-browser";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
    };

    # Override desktop entry to force the correct profile
    xdg.desktopEntries.zen-beta = {
      name = "Zen";
      genericName = "Web Browser";
      exec = "zen-beta --profile ${config.xdg.configHome}/zen/${profile} --name zen-beta %U";
      icon = "zen-browser";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/vnd.mozilla.xul+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      actions = {
        new-window = {
          name = "New Window";
          exec = "zen-beta --profile ${config.xdg.configHome}/zen/${profile} --new-window %U";
        };
        new-private-window = {
          name = "New Private Window";
          exec = "zen-beta --profile ${config.xdg.configHome}/zen/${profile} --private-window %U";
        };
      };
    };

    programs.zen-browser = {
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };

      profiles.${profile} = {
        id = 0;
        name = profile;
        isDefault = true;

        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          onepassword-password-manager
          darkreader
          # Wikiwand, vidIQ, and Grammarly are installed manually (not in NUR)
        ];

        search = {
          force = true;
          default = "duckduckgo";
        };

        # Zen Mods (by UUID from theme store)
        mods = [
          "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
          "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
          "79dde383-4fe7-404a-a8e6-9be440022542" # Tidy Popup
          "378ba8b9-cd36-45f5-88df-595df5288795" # Add new tab urlbar icon
          "ae7868dc-1fa1-469e-8b89-a5edf7ab1f24" # Load Bar
          "58649066-2b6f-4a5b-af6d-c3d21d16fc00" # Private Mode Highlighting
          "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
          "f4866f39-cfd6-4498-ab92-54213b8279dc" # Animations Plus
        ];

        # Workspaces
        spacesForce = true;
        spaces = {
          "Live" = {
            id = "0a2e02a7-e275-4b87-b2b0-a09f9eea25db";
            icon = "🔴";
            position = 1;
            container = 1;
          };
          "Home" = {
            id = "6999010f-0d9f-4762-b172-3c8085827d3d";
            icon = "🏡";
            position = 2;
            container = 1;
          };
          "Research" = {
            id = "25b1ffc3-3866-41f2-b95d-96ad37020dd0";
            icon = "📖";
            position = 3;
            container = 1;
          };
          "Watching" = {
            id = "f8724f7d-3fde-4f50-b8fe-a08347485c8d";
            icon = "👀";
            position = 4;
            container = 1;
          };
          "Leaky Abstractions" = {
            id = "46cae16d-0d8e-4a0b-80fe-29ddc0245ac7";
            icon = "🔧";
            position = 5;
            container = 7;
          };
          "Smoking Squid" = {
            id = "99e1f307-afd0-40c7-afcf-3762a4dfe82f";
            icon = "🐙";
            position = 6;
            container = 2;
          };
          "The Considered Shops" = {
            id = "522ae6de-e64e-460d-94e3-4d6990542d9e";
            icon = "🛋️";
            position = 7;
            container = 6;
          };
        };

        # Containers
        containers = {
          "Smoking Squid" = {
            id = 2;
            icon = "circle";
            color = "red";
          };
          "The Considered Shops" = {
            id = 6;
            icon = "cart";
            color = "turquoise";
          };
          "Leaky Abstractions" = {
            id = 7;
            icon = "circle";
            color = "red";
          };
        };
        containersForce = true;

        settings = {
          # Extensions
          "extensions.autoDisableScopes" = 0;
          "extensions.enabledScopes" = 15;
          "extensions.allowPrivateBrowsingByDefault" = true;

          # Skip first-run onboarding (prevents Zen from wiping session data)
          "zen.welcomeScreen.enabled" = false;
          "zen.welcomeScreen.seen" = true;
          "browser.startup.homepage_override.mstone" = "ignore";
          "browser.aboutwelcome.enabled" = false;
          "startup.homepage_welcome_url" = "";
          "startup.homepage_welcome_url.additional" = "";
          "trailhead.firstrun.didSeeAboutWelcome" = true;

          # Privacy
          "privacy.donottrackheader.enabled" = true;
          "privacy.globalprivacycontrol.was_ever_enabled" = true;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "dom.security.https_only_mode_ever_enabled" = true;
          "network.dns.disablePrefetch" = true;
          "network.http.speculative-parallel-limit" = 0;
          "network.prefetch-next" = false;

          # General
          "general.autoScroll" = true;
          "browser.ml.linkPreview.enabled" = true;
          "browser.warnOnQuitShortcut" = false;
          "widget.gtk.overlay-scrollbars.enabled" = false;
          "dom.disable_open_during_load" = false;
          "browser.translations.neverTranslateLanguages" = "en,de";

          # Media
          "media.hardwaremediakeys.enabled" = false;
          "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = false;

          # Sync
          "services.sync.declinedEngines" = "passwords,creditcards,addresses";
          "services.sync.engine.passwords" = false;
          "services.sync.engine.workspaces" = true;

          # Zen UI
          "zen.theme.hide-unified-extensions-button" = true;
          "zen.urlbar.behavior" = "float";
          "zen.glance.activation-method" = "ctrl";
          "zen.view.compact.enable-at-startup" = false;
          "zen.view.show-newtab-button-top" = false;
          "zen.view.use-single-toolbar" = false;
          "zen.tabs.show-newtab-vertical" = false;
          "zen.tabs.ctrl-tab.ignore-essential-tabs" = true;
          "zen.tabs.ctrl-tab.ignore-pending-tabs" = true;
          "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true;
          "zen.workspaces.hide-default-container-indicator" = false;
          "zen.workspaces.indicator-name-center" = false;
          "zen.workspaces.show-workspace-indicator" = true;

          # Mod preferences
          "mod.cleanedurlbar.customcolor" = "hsl(0 0 10)";
          "mod.cleanedurlbar.customselectcolor" = "rgba(80, 80, 250, 0.75)";
          "mod.cleanedurlbar.customselectfontcolor" = "rgba(255,255,255,1)";
          "mod.cleanedurlbar.customtransparency" = "40%";
          "mod.superpins.essentials.grid-count" = "1";
          "mod.superpins.pins.grid-count" = "1";
          "mod.tidypopup.hovercolor" = "rgba(80, 80, 250, 1)";
          "mod.tidypopup.usecustomhovercolor" = false;
          "theme.better-active-tab.on-right" = false;
          "theme.better_uniextbtn.default" = "Default";

          # Essentials/Pins mod settings
          "uc.essentials.auto-grow" = false;
          "uc.essentials.gap" = "Normal";
          "uc.essentials.same-height" = false;
          "uc.essentials.transition-bg" = false;
          "uc.essentials.transition-speed" = "100ms";
          "uc.essentials.width" = "Normal";
          "uc.pins.legacy-layout" = false;
          "uc.pins.transition-speed" = "100ms";
          "uc.private-browsing-top-bar.border-style" = "default";
          "uc.private-browsing-top-bar.color" = "default";
          "uc.private-browsing-top-bar.highlighting-style" = "gradient";
          "uc.tabs.dim_unloaded" = false;
        };
      };
    };
  };
}
