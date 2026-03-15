{ lib, ... }:

with lib;
{
  options.internal.desktop.core.workspaces = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Workspace name identifier (used as key)";
        };
        displayName = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Display name for the workspace. Defaults to name if null.";
        };
        monitor = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Output/monitor to bind this workspace to (e.g. 'DP-1'). Null means compositor decides.";
        };
      };
    });
    default = [];
    description = "Named workspace definitions. Set from home config with monitor bindings.";
  };
}
