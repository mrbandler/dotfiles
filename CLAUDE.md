# Git

- Conventional Commits with hierarchical scopes: `type(nix/scope): message`
- No "Co-Authored-By" or "Generated with Claude" in commits
- Don't commit `docs/plans/` — keep plans local only

# Nix

- Run nix commands from `./nix` directory (where `flake.nix` lives)
- Nix flakes only see git-staged files — stage new files before building
- Flake uses [Snowfall Lib](https://snowfall.org/guides/lib/quickstart/)
- Snowfall auto-imports `default.nix` in expected directories (`modules/`, `systems/`, `homes/`, `lib/`, `overlays/`)
- Namespace is `internal` — options are `internal.<category>.<module>`
- Currently focusing on `zeus` host — `ade` may be broken

# Verification

- Build specific config before committing: `nix build .#homeConfigurations.mrbandler@zeus`
- For system changes: `nix build .#nixosConfigurations.zeus`
