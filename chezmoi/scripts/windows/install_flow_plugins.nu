let builtins = [
    "0ECADE17459B49F587BF81DC3A125110", # Browser Bookmarks
    "CEA0FDFC6D3B4085823D60DC76F28855", # Calculator
    "572be03c74c642baae319fc283e561a8", # Explorer
    "6A122269676E40EB86EB543B945932B9", # Plugin Indicator
    "9f8f9b14-2518-4907-b211-35ab6290dee7", # Plugins Manager
    "b64d0a79-329a-48b0-b53f-d658318a1bf6", # Process Killer
    "791FC278BA414111B8D1886DFE447410", # Program
    "D409510CD0D2481F853690A07E6DC426", # Shell
    "CEA08895D2544B019B2E9C5009600DF4", # System Commands
    "0308FD86DE0A4DEE8D62B9B535370992", # URL
    "565B73353DBF4806919830B9202EE3BF", # Web Searches
    "5043CETYU6A748679OPA02D27D99677A" # Windows Settings
]

let pluginsPath = ($env.APPDATA | path join "FlowLauncher\\Plugins")
let settings = open ($env.APPDATA | path join "FlowLauncher\\Settings\\Settings.json")
let registry = http get "https://raw.githubusercontent.com/Flow-Launcher/Flow.Launcher.PluginsManifest/plugin_api_v2/plugins.json"
let installed = ls $pluginsPath |
                     where type == "dir" |
                     each { |dir| $dir.name |
                     path join "plugin.json" } |
                     where { $in | path exists } |
                     each { |file| open $file }

print $"Killing Flow..."
ps | where name == "Flow.Launcher.exe" | each { |proc| kill $proc.pid }

# Look for plugins to uninstall.
for entry in $installed {
    let foundInSettings = (($settings.PluginSettings.Plugins | transpose id plugin | where id == $entry.ID) | length) > 0
    if ($foundInSettings) { continue }

    print $"Uninstalling plugin '($entry.Name)'..."
    let pluginDir = ($pluginsPath | path join ($"($entry.Name | str trim)-($entry.Version | str trim)"))
    if ($pluginDir | path exists) { rm -r $pluginDir }
}

# Look for plugins to install.
for entry in ($settings.PluginSettings.Plugins | transpose id plugin | where { |entry| not ($entry.id in $builtins) }) {
    let isInstalled = (($installed | where ID == $entry.id) | length) > 0
    if ($isInstalled) { continue }

    print $"Found uninstalled plugin '($entry.plugin.Name)'"

    let registryEntry = $registry | where ID == $entry.id | first
    if ($registryEntry == null) { continue }

    print $"Found remote registry entry for '($entry.plugin.Name)'"

    print $"Downloading '($entry.plugin.Name)'..."
    let zipPath = ($env.TEMP | path join ($entry.id + ".zip"))
    if ($zipPath | path exists) { rm $zipPath }
    http get $registryEntry.UrlDownload | save $zipPath

    print $"Installing '($entry.plugin.Name)'..."
    let pluginPath = $pluginsPath | path join ($"($registryEntry.Name | str trim)-($registryEntry.Version | str trim)")
    7z x $zipPath -o$"($pluginPath)" -y | null
}

print $"Restarting Flow..."
let flowPath = ($env.LOCALAPPDATA | path join "FlowLauncher\\Flow.Launcher.exe")
if ($flowPath | path exists) { start $flowPath }
