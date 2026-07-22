# monitor-profile-switch.nu — Nushell module + CLI
#
# Switch the monitor between sRGB (editing) and HDR Effect (gaming) over
# DDC/CI. Dual-use:
#   - As a module:  use monitor-profile-switch.nu *
#                   monitor profile switch {srgb|hdr|toggle|status|get|probe}
#   - As a script:  nu monitor-profile-switch.nu {srgb|hdr|toggle|status|get|probe}
#
# Per-host consts (DISPLAY_SERIAL, VCP_FEATURE, ...) come from the sibling
# monitor-profile-config.nu, which is Nix-generated at activation.

use monitor-profile-config.nu *

# CANDIDATES — feature codes scanned by `probe` for register discovery.
# Not host-specific, lives in the static script.
const CANDIDATES = [15 F5 F6 F7 F8 FA FD FE F4 EF FF]

# --- private helpers ----------------------------------------------------------

def ddc [args: list<string>] {
  mut full = ["--sn" $DISPLAY_SERIAL]
  if $USE_SIDECHANNEL {
    $full = ($full | append "--i2c-source-addr=x50")
  }
  $full = ($full | append $args)
  ^ddcutil ...$full
}

def set-mode [primary: string, secondary: string] {
  ddc [setvcp $VCP_FEATURE $primary "--permit-unknown-feature" "--noverify"]
  if $SECONDARY_ENABLE {
    ddc [setvcp $SECONDARY_FEATURE $secondary "--permit-unknown-feature" "--noverify"]
  }
}

def current-mode [] {
  let res = (ddc [getvcp $VCP_FEATURE] | complete)
  let m = ($res.stdout | parse --regex 'sl=(?<val>0x[0-9a-fA-F]+)')
  if ($m | is-empty) { "" } else { $m.val.0 }
}

def apply-srgb [] {
  set-mode $SRGB_VALUE $SECONDARY_SRGB
  print "Monitor -> sRGB (editing)"
}

def apply-hdr [] {
  set-mode $HDR_VALUE $SECONDARY_HDR
  print "Monitor -> HDR Effect (gaming)"
}

def apply-toggle [] {
  let cur = (current-mode | str downcase)
  if $cur == ($SRGB_VALUE | str downcase) { apply-hdr } else { apply-srgb }
}

def show-status [] {
  print $"Current ($VCP_FEATURE) value: (current-mode)"
}

def show-mode [] {
  let cur = (current-mode | str downcase)
  if $cur == ($SRGB_VALUE | str downcase) {
    print "srgb"
  } else if $cur == ($HDR_VALUE | str downcase) {
    print "hdr"
  } else {
    print "unknown"
  }
}

def show-probe [] {
  print $"Reading candidate features on ($DISPLAY_SERIAL):"
  ddc ([getvcp] | append $CANDIDATES)
  print ""
  print "Run in sRGB (OSD) and again in HDR Effect (OSD); the feature that"
  print "changes value is the mode register."
}

def show-usage [] {
  print "Usage: monitor profile switch {srgb|hdr|toggle|status|get|probe}"
  print ""
  print "  srgb     switch to sRGB editing mode"
  print "  hdr      switch to HDR Effect gaming mode"
  print "  toggle   flip between the two"
  print "  status   print the current raw mode value"
  print "  get      print 'srgb' | 'hdr' | 'unknown' (for scripting)"
  print "  probe    dump candidate feature values for discovery"
}

# --- exported module subcommands (for `use monitor-profile-switch.nu *`) -------

export def "monitor profile switch srgb"   [] { apply-srgb }
export def "monitor profile switch hdr"    [] { apply-hdr }
export def "monitor profile switch toggle" [] { apply-toggle }
export def "monitor profile switch status" [] { show-status }
export def "monitor profile switch get"    [] { show-mode }
export def "monitor profile switch probe"  [] { show-probe }
export def "monitor profile switch"        [] { show-usage }

# --- script entry (for `nu monitor-profile-switch.nu <subcmd>`) ---------------

def main [subcmd?: string] {
  match $subcmd {
    "srgb"   => { apply-srgb }
    "hdr"    => { apply-hdr }
    "toggle" => { apply-toggle }
    "status" => { show-status }
    "get"    => { show-mode }
    "probe"  => { show-probe }
    null     => { show-usage }
    _        => {
      print --stderr $"unknown subcommand: ($subcmd)"
      show-usage
      exit 1
    }
  }
}
