# Fix uhk-agent permission issues with smart-macro-docs directory
# The app copies files from nix store preserving read-only permissions.
# Run app, if it fails due to permissions, fix and retry automatically.
{ ... }:

final: prev: {
  uhk-agent = prev.uhk-agent.overrideAttrs (oldAttrs: {
    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        wrapProgram $out/bin/uhk-agent \
          --run 'chmod -R u+w "$HOME/.config/uhk-agent/smart-macro-docs" 2>/dev/null || true'
      '';
  });
}
