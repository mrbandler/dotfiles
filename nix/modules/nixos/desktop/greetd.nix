{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.desktop.greetd;
  desktopCfg = config.${namespace}.desktop;
in
{
  options.${namespace}.desktop.greetd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable greetd display manager.";
    };

    greeter = mkOption {
      type = types.enum [
        "tuigreet"
        "sysc-greet"
      ];
      default = "tuigreet";
      description = "Greeter to use with greetd.";
    };

    tuigreet = {
      greeting = mkOption {
        type = types.str;
        default = "Welcome";
        description = "Greeting message to display.";
      };

      time = mkOption {
        type = types.bool;
        default = true;
        description = "Display the current date and time.";
      };

      remember = mkOption {
        type = types.bool;
        default = true;
        description = "Remember last logged-in user.";
      };

      rememberSession = mkOption {
        type = types.bool;
        default = true;
        description = "Remember last selected session.";
      };

      asterisks = mkOption {
        type = types.bool;
        default = true;
        description = "Display asterisks when typing password.";
      };

      theme = mkOption {
        type = types.nullOr (
          types.enum [
            "catppuccin-latte"
            "catppuccin-frappe"
            "catppuccin-macchiato"
            "catppuccin-mocha"
          ]
        );
        default = "catppuccin-mocha";
        description = "Theme to use for tuigreet. Note: tuigreet doesn't natively support themes, this will set terminal colors.";
      };
    };

    syscGreet = {
      compositor = mkOption {
        type = types.enum [
          "niri"
          "hyprland"
          "sway"
        ];
        default = "niri";
        description = "Compositor to use with sysc-greet.";
      };

      settings = mkOption {
        type = types.attrs;
        default = { };
        description = "Additional settings for sysc-greet.";
        example = literalExpression ''
          {
            initial_session = {
              command = "Hyprland";
              user = "username";
            };
          }
        '';
      };
    };

    defaultSession = mkOption {
      type = types.str;
      default = "niri-session";
      description = "Default session command to run.";
      example = "Hyprland";
    };

    autoLogin = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable automatic login.";
      };

      user = mkOption {
        type = types.str;
        default = "";
        description = "User to automatically log in.";
      };
    };
  };

  config = mkIf (desktopCfg.enable && cfg.enable) {
    # Disable SDDM if greetd is enabled
    ${namespace}.desktop.sddm.enable = mkForce false;

    # Configure based on greeter choice
    services.greetd = mkIf (cfg.greeter == "tuigreet") {
      enable = true;
      settings = {
        default_session =
          let
            flags = concatStringsSep " " (
              [ ]
              ++ optional cfg.tuigreet.time "--time"
              ++ optional cfg.tuigreet.remember "--remember"
              ++ optional cfg.tuigreet.rememberSession "--remember-session"
              ++ optional cfg.tuigreet.asterisks "--asterisks"
              ++ [ "--greeting '${cfg.tuigreet.greeting}'" ]
              ++ [ "--cmd ${cfg.defaultSession}" ]
            );
          in
          {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet ${flags}";
            user = "greeter";
          };

        initial_session = mkIf cfg.autoLogin.enable {
          command = cfg.defaultSession;
          user = cfg.autoLogin.user;
        };
      };
    };

    # Use sysc-greet's native module
    # services.sysc-greet = mkIf (cfg.greeter == "sysc-greet") (
    #   {
    #     enable = true;
    #     compositor = cfg.syscGreet.compositor;
    #   }
    #   // cfg.syscGreet.settings
    # );

    # Set VT for tuigreet
    systemd.services.greetd.serviceConfig = mkIf (cfg.greeter == "tuigreet") {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    # Ensure greeter user exists for tuigreet
    users.users.greeter = mkIf (cfg.greeter == "tuigreet") {
      isSystemUser = true;
      group = "greeter";
    };
    users.groups.greeter = mkIf (cfg.greeter == "tuigreet") { };
  };
}
