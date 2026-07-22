#!/usr/bin/env nu
# monitor-profiles-watcher.nu
#
# Watches niri's event stream. Forces sRGB while any of the given trigger
# app_ids is open; switches to HDR when the last trigger app closes.
#
# `nu script.nu` and `nu -c "..."` do NOT load the user's config.nu (only
# the interactive `nu` REPL does), so this script imports the switch module
# explicitly. The home-manager monitor-profiles module rewrites the
# absolute path below at activation time from a placeholder token.

use @USER_HOME@/.config/nushell/modules/monitor-profile-switch.nu *

def main [...triggers: string] {
  let state = ($env.XDG_RUNTIME_DIR? | default "/tmp") | path join "monitor-profiles-open"
  "" | save -f $state
  print $"watching for app_ids: ($triggers | str join ', ')"

  ^niri msg --json event-stream | lines | each { |line|
    handle $line $triggers $state
    null
  } | ignore
}

def handle [line: string, triggers: list<string>, state: string] {
  let ev = try { $line | from json } catch { return }

  let snapshot = ($ev | get -i WindowsChanged)
  if $snapshot != null {
    on-snapshot $snapshot.windows $triggers $state
    return
  }

  let opened = ($ev | get -i WindowOpenedOrChanged)
  if $opened != null {
    let w = $opened.window
    let app = ($w | get -i app_id | default "")
    if ($app in $triggers) {
      on-open ($w.id | into string) $state
    }
    return
  }

  let closed = ($ev | get -i WindowClosed)
  if $closed != null {
    on-close ($closed.id | into string) $state
  }
}

def read-open [state: string]: nothing -> list<string> {
  try { open $state | lines | where { |l| $l != "" } } catch { [] }
}

def write-open [open: list<string>, state: string] {
  $open | str join "\n" | save -f $state
}

# WindowsChanged snapshot: rebuild state from scratch, force sRGB if any
# trigger apps are present. Restart-safe path.
def on-snapshot [windows, triggers: list<string>, state: string] {
  let open = ($windows
    | where { |w| ($w | get -i app_id | default "") in $triggers }
    | each { |w| $w.id | into string })
  write-open $open $state
  if (not ($open | is-empty)) {
    print "snapshot has trigger app(s) open -> sRGB"
    monitor profile switch srgb
  }
}

def on-open [id: string, state: string] {
  let open = (read-open $state)
  if ($id in $open) { return }
  let was_empty = ($open | is-empty)
  write-open ($open | append $id) $state
  if $was_empty {
    print "trigger app opened -> sRGB"
    monitor profile switch srgb
  }
}

def on-close [id: string, state: string] {
  let open = (read-open $state)
  if ($id not-in $open) { return }
  let new_open = ($open | where { |x| $x != $id })
  write-open $new_open $state
  if ($new_open | is-empty) {
    print "last trigger app closed -> HDR"
    monitor profile switch hdr
  }
}
