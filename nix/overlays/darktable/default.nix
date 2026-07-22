# Track darktable master to get the neural restore module (raw denoise /
# denoise / upscale via ONNX). The feature was added post-5.4.1 and is not
# in any tagged release yet, so we override src + enable -DUSE_AI=ON and
# wire in nixpkgs' onnxruntime.
{ ... }:

final: prev: {
  darktable = prev.darktable.overrideAttrs (old: {
    version = "5.5.0-unstable-2026-06-11";

    src = final.fetchFromGitHub {
      owner = "darktable-org";
      repo = "darktable";
      rev = "1194d6d01bf7adebe963e146d7dfa98d46bbf2b0";
      fetchSubmodules = true;
      hash = "sha256-rLYvJX55idsQhYDVZgPP9oZoENYH+jdPLEhxO4Bi88c=";
    };

    buildInputs = (old.buildInputs or [ ]) ++ [
      final.onnxruntime
      # libarchive is required when USE_AI=ON: darktable extracts the model
      # ZIPs the runtime downloader pulls from the model repo.
      final.libarchive
      # potrace became a hard `find_package(Potrace REQUIRED)` in master
      # (src/CMakeLists.txt:325); 5.4.1 didn't link against it.
      final.potrace
    ];

    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      # Enable the AI subsystem (src/ai + neural restore module).
      "-DUSE_AI=ON"
      # Use nixpkgs' onnxruntime; the sandbox can't reach the auto-downloader.
      "-DONNXRUNTIME_OFFLINE=ON"
      # USE_AI_DOWNLOAD defaults ON and gates the *runtime* model-download UI
      # in preferences → AI. It is NOT a build-time fetch, so leave it on.

      # fetchFromGitHub strips .git, so get_git_version_string.sh falls back to
      # "unknown-version" — which breaks the model registry's release lookup
      # (compatible_releases is keyed by MAJOR.MINOR.PATCH). Match the
      # upstream tag on this commit's branch.
      "-DPROJECT_VERSION=5.5.0"
    ];

    # The release-tag-based versionCheckHook expectation doesn't match the
    # `git describe` fallback on a master snapshot.
    doInstallCheck = false;

    # src/ai/backend_onnx.c lazy-loads libonnxruntime.so by bare filename
    # via g_module_open, relying on LD_LIBRARY_PATH at runtime. The base
    # derivation's wrapper only adds $out/lib/darktable + ocl-icd, so we
    # extend gappsWrapperArgs with onnxruntime's lib dir.
    preFixup =
      (old.preFixup or "")
      + ''
        gappsWrapperArgs+=(
          --prefix LD_LIBRARY_PATH ":" "${final.onnxruntime}/lib"
        )
      '';
  });
}
