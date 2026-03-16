{ pkgs, ... }:
pkgs.buildNpmPackage {
  pname = "praxis";
  version = "0.1.0";
  src = ./.;
  installPhase = ''
    runHook preInstall
    test -d /build/.local/share/vicinae/extensions/praxis || (echo "Build output not found at /build/.local/share/vicinae/extensions/praxis" && exit 1)
    mkdir -p $out
    cp -r /build/.local/share/vicinae/extensions/praxis/* $out/
    runHook postInstall
  '';
  npmDeps = pkgs.importNpmLock { npmRoot = ./.; };
  npmConfigHook = pkgs.importNpmLock.npmConfigHook;
}
