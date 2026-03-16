{ pkgs, inputs, ... }:

let
  vicinae = inputs.vicinae-extensions.inputs.vicinae;
  mkExt = vicinae.packages.${pkgs.stdenv.hostPlatform.system}.mkVicinaeExtension;
in
mkExt {
  pname = "praxis";
  version = "0.1.0";
  src = ./.;
}
