# Module to manange the machines state via the Desired State Configuration (DSC).
#
# Exports the following environment variables:
# - STATE_PREFIX: Path to the state configuration files.
# - STATE_DEFAULT_CONFIG: Path to the default configuration file.
# - STATE_BUILD: Path to the build script.
# - STATE_CHECK: Path to the build script.
# - STATE_APPLY: Path to the apply script.

# Paths to state configuration files are relative to the STATE_PREFIX.
# The STATE_PREFIX can be changed during the current session by using the `prefix` command.

export-env {
    $env.STATE_PREFIX = $env.USERPROFILE | path join ".local\\share\\chezmoi\\chezmoi\\state\\dsc"
    $env.STATE_DEFAULT_CONFIG = $env.STATE_PREFIX | path join "configuration.dsc.yml"
    $env.STATE_BUILD = $env.STATE_PREFIX | path join "build.ps1"
    $env.STATE_CHECK = $env.STATE_PREFIX | path join "check.ps1"
    $env.STATE_APPLY = $env.STATE_PREFIX | path join "apply.ps1"
}

# Sets the prefix path for the state configuration files.
#
# Setting the prefix path allows one to change the location
# of the state configuration files during the current session.
export def --env prefix [
    path: string # Path to set as prefix.
] {
    echo $path
    $env.STATE_PREFIX = $path
}

export def build [entry: string, output: string = None] {
    let $entry_path: string = ($env.STATE_PREFIX | path join $entry)
    if not ($entry_path | path exists) {
        error make {
            msg: "Entry file not found",
            label: {
                text: "Please check the relative path against $env.STATE_PREFIX and try again",
                span: (metadata $entry).span
            }
        }
    }

    let $output_path = if $output == None { $env.STATE_DEFAULT_CONFIG } else { $output }
    pwsh -File $env.STATE_BUILD -Path $entry_path -Output $output_path
}

export def "build inplace" [entry: string, output: string = None]: nothing -> string {
    let $output_path = if $output == None { $env.STATE_DEFAULT_CONFIG } else { $output }

    build $entry $output_path
    open $output_path
}

export def check [config: string = None, --verbose] {

    if ($config == None) {
        if ($verbose) {
            pwsh -File $env.STATE_CHECK -Verbose
        } else {
            pwsh -File $env.STATE_CHECK
        }
    } else {
        if ($verbose) {
             pwsh -File $env.STATE_CHECK -PrebuiltConfig $config -Verbose
        } else {
            pwsh -File $env.STATE_CHECK -PrebuiltConfig $config
        }
    }
}

export def "check inplace" [--verbose]: string -> nothing {
    $in | to yaml | save $env.STATE_DEFAULT_CONFIG -f

    if ($verbose) {
        check $env.STATE_DEFAULT_CONFIG --verbose
    } else {
        check $env.STATE_DEFAULT_CONFIG
    }
}

export def apply [config: string = None, --run-before, --run-after] {
    ensure-admin

    if ($config == None) {
        pwsh -File $env.STATE_APPLY
    } else {
        if ($run_before and $run_after) {
            pwsh -File $env.STATE_APPLY -PrebuiltConfig $config -RunBefore -RunAfter
        } else if ($run_before) {
            pwsh -File $env.STATE_APPLY -PrebuiltConfig $config -RunBefore
        } else if ($run_after) {
            pwsh -File $env.STATE_APPLY -PrebuiltConfig $config -RunAfter
        } else {
            pwsh -File $env.STATE_APPLY -PrebuiltConfig $config
        }
    }
}

export def "apply inplace" [--run-before, --run-after]: string -> nothing {
    ensure-admin

    $in | to yaml | save $env.STATE_DEFAULT_CONFIG -f

    if ($run_before and $run_after) {
        apply $env.STATE_DEFAULT_CONFIG --run-before --run-after
    } else if ($run_before) {
        apply $env.STATE_DEFAULT_CONFIG --run-before
    } else if ($run_after) {
        apply $env.STATE_DEFAULT_CONFIG --run-after
    } else {
        apply $env.STATE_DEFAULT_CONFIG
    }
}


def ensure-admin [] {
    if (is-admin) { return }

    error make {
        msg: "Please run the command as an administrator",
    }
}
