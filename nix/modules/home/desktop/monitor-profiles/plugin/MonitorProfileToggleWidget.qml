import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services

PluginComponent {
    id: root

    // "srgb" | "hdr" | "unknown"
    property string mode: "unknown"

    // Absolute path to the dual-use switch module, resolved at runtime —
    // no Nix substitution needed. `nu script.nu <subcmd>` triggers the
    // script's `def main` dispatcher. We do not use `nu -c` because
    // `nu -c` does not load config.nu and our module wouldn't be in scope.
    readonly property string switchScript:
        Quickshell.env("HOME") + "/.config/nushell/modules/monitor-profile-switch.nu"

    // ---- status poll ----------------------------------------------------
    Process {
        id: statusProc
        command: ["nu", root.switchScript, "get"]
        running: false
        stdout: SplitParser {
            onRead: line => root.mode = line.trim()
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    // ---- click action ---------------------------------------------------
    Process {
        id: toggleProc
        command: ["nu", root.switchScript, "toggle"]
        running: false
        onExited: statusProc.running = true
    }

    pillClickAction: (x, y, width, section, screen) => {
        toggleProc.running = true
        ToastService.showInfo(
            "Monitor profile",
            root.mode === "srgb" ? "Switching to HDR…" : "Switching to sRGB…"
        )
    }

    // ---- bar pills ------------------------------------------------------
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS
            DankIcon {
                name: root.mode === "srgb" ? "palette"
                    : root.mode === "hdr"  ? "hdr_on"
                    :                        "monitor"
                color: root.mode === "srgb" ? Theme.primary : Theme.surfaceVariantText
                font.pixelSize: Theme.iconSize - 4
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                text: root.mode === "srgb" ? "sRGB"
                    : root.mode === "hdr"  ? "HDR"
                    :                        "—"
                color: root.mode === "srgb" ? Theme.primary : Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeMedium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS
            DankIcon {
                name: root.mode === "srgb" ? "palette"
                    : root.mode === "hdr"  ? "hdr_on"
                    :                        "monitor"
                color: root.mode === "srgb" ? Theme.primary : Theme.surfaceVariantText
                font.pixelSize: Theme.iconSize - 4
                anchors.horizontalCenter: parent.horizontalCenter
            }
            StyledText {
                text: root.mode === "srgb" ? "sRGB"
                    : root.mode === "hdr"  ? "HDR"
                    :                        "—"
                color: root.mode === "srgb" ? Theme.primary : Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
