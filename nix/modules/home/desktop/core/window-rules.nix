{ lib, ... }:

with lib;
let
  matchModule = types.submodule {
    options = {
      appId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Wayland app-id regex pattern to match";
      };
      title = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Window title regex pattern to match";
      };
      atStartup = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Only match windows opened at startup";
      };
    };
  };
in
{
  options.internal.desktop.core.windowRules = mkOption {
    type = types.listOf (types.submodule {
      options = {
        matches = mkOption {
          type = types.listOf matchModule;
          default = [];
          description = "Match conditions (any must match)";
        };
        excludes = mkOption {
          type = types.listOf matchModule;
          default = [];
          description = "Exclude conditions (any excludes the window)";
        };
        properties = mkOption {
          type = types.attrs;
          default = {};
          description = "Freeform properties passed through to the compositor (e.g. open-on-workspace, open-floating)";
        };
      };
    });
    default = [];
    description = "Window rules for controlling window placement and behavior.";
  };
}
