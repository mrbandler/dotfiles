{ ... }:

{
  internal.desktop.monitor-profiles = {
    enable = true;

    # LG 38GN950 — discovered via `ddcutil detect` and OSD-diff feature scan.
    displaySerial = "112NTPCHM864";
    vcpFeature = "15";
    srgbValue = "0x0f";
    hdrValue = "0x27";

    # Apps that must use sRGB.
    # TODO: verify these app_ids match reality. After first deploy, run
    #   `niri msg windows`
    # while Blender / RapidRAW are open and compare `App ID: "..."` to the
    # entries below. Update if they differ.
    triggerApps = [
      "Blender"
      "rapidraw"
      "darktable"
    ];
  };
}
