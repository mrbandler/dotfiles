{ lib, ... }:

with lib;
{
  options.internal.desktop.core.commands = {
    # === Applications ===
    applications = {
      terminal = mkOption {
        type = types.listOf types.str;
        default = [ "sh" "-c" "$TERMINAL" ];
        description = "Command to launch terminal";
      };
      fileManager = mkOption {
        type = types.listOf types.str;
        default = [ "sh" "-c" "$FILEMANAGER" ];
        description = "Command to launch file manager";
      };
      browser = mkOption {
        type = types.listOf types.str;
        default = [ "sh" "-c" "$BROWSER" ];
        description = "Command to launch browser";
      };
      launcher = mkOption {
        type = types.listOf types.str;
        default = [ "sh" "-c" "$LAUNCHER" ];
        description = "Command to launch application launcher";
      };
    };

    # === Scratch Terminal ===
    scratchTerminal = {
      spawn = mkOption {
        type = types.str;
        default = "\${TERMINAL} start --class scratch-terminal";
        description = "Command to launch the scratch terminal. Must set a Wayland app-id for window matching.";
      };
      command = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Command to run inside the scratch terminal. Null uses the terminal's default shell.";
      };
      appId = mkOption {
        type = types.str;
        default = "scratch-terminal";
        description = "Wayland app-id for window matching between spawn command and window rule.";
      };
      check = mkOption {
        type = types.str;
        default = "niri msg --json windows";
        description = "Command that outputs JSON listing open windows.";
      };
      filter = mkOption {
        type = types.str;
        default = ''.[] | select(.app_id == "{appId}") | .id'';
        description = "jq expression to extract window id from check output. {appId} is substituted at build time.";
      };
      close = mkOption {
        type = types.str;
        default = "niri msg action close-window --id {id}";
        description = "Command to close the window. {id} is substituted at runtime.";
      };
    };

    # === Desktop Shell ===
    desktopShell = {
      spotlight = mkOption {
        type = types.listOf types.str;
        default = [ "dms" "ipc" "call" "spotlight" "toggle" ];
        description = "Command to toggle spotlight/launcher";
      };
      notifications = mkOption {
        type = types.listOf types.str;
        default = [ "dms" "ipc" "call" "notifications" "toggle" ];
        description = "Command to toggle notifications panel";
      };
      lock = mkOption {
        type = types.listOf types.str;
        default = [ "dms" "ipc" "call" "lock" "lock" ];
        description = "Command to lock screen";
      };
      powerMenu = mkOption {
        type = types.listOf types.str;
        default = [ "dms" "ipc" "call" "powermenu" "toggle" ];
        description = "Command to toggle power menu";
      };
      processlist = mkOption {
        type = types.listOf types.str;
        default = [ "dms" "ipc" "call" "processlist" "toggle" ];
        description = "Command to toggle process list/task manager";
      };
    };

    # === Media ===
    media = {
      volumeUp = mkOption {
        type = types.listOf types.str;
        default = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" "-l" "1.0" ];
        description = "Command to increase volume";
      };
      volumeDown = mkOption {
        type = types.listOf types.str;
        default = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
        description = "Command to decrease volume";
      };
      mute = mkOption {
        type = types.listOf types.str;
        default = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        description = "Command to toggle mute";
      };
      micMute = mkOption {
        type = types.listOf types.str;
        default = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
        description = "Command to toggle microphone mute";
      };
      play = mkOption {
        type = types.listOf types.str;
        default = [ "playerctl" "play-pause" ];
        description = "Command to play/pause media";
      };
      stop = mkOption {
        type = types.listOf types.str;
        default = [ "playerctl" "stop" ];
        description = "Command to stop media";
      };
      prev = mkOption {
        type = types.listOf types.str;
        default = [ "playerctl" "previous" ];
        description = "Command to play previous track";
      };
      next = mkOption {
        type = types.listOf types.str;
        default = [ "playerctl" "next" ];
        description = "Command to play next track";
      };
    };
  };
}
