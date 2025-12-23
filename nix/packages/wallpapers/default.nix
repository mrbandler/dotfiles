{
  lib,
  stdenv,
  namespace,
  ...
}:

stdenv.mkDerivation {
  pname = "${namespace}-wallpapers";
  version = "1.0.0";

  src = ../../wallpapers;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wallpapers

    # Copy only PNG files, preserving directory structure
    find . -type f -name "*.png" | while read -r file; do
      dir=$(dirname "$file")
      mkdir -p "$out/share/wallpapers/$dir"
      cp "$file" "$out/share/wallpapers/$file"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Catppuccin-themed wallpapers for ${namespace}";
    platforms = platforms.all;
  };
}
