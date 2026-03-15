# Git

- Conventional Commits with hierarchical scopes: `type(nix/scope): message`
- No "Co-Authored-By" or "Generated with Claude" in commits
- Don't commit `docs/` — keep plans and specs local only

# Nix

- Run nix commands from `./nix` directory (where `flake.nix` lives)
- Nix flakes only see git-staged files — stage new files before building
- Flake uses [Snowfall Lib](https://snowfall.org/guides/lib/quickstart/)
- Snowfall auto-imports `default.nix` in expected directories (`modules/`, `systems/`, `homes/`, `lib/`, `overlays/`)
- Namespace is `internal` — options are `internal.<category>.<module>`
- In home-manager modules, use `internal` directly — don't use `namespace` parameter (only works in NixOS modules)
- Currently focusing on `zeus` host — `ade` may be broken

## Module Structure

- Modules are organized by domain: `apps/`, `cli/`, `desktop/`, `development/`, `web/`
- Top-level standalone modules: `security/`, `theme/`, `env/`, `defaults/`, `maintenance/`
- Every subdirectory needs a `default.nix` for Snowfall auto-import
- Namespace follows directory path: `internal.<domain>.<sub>.<module>`

## Module Creation Rules (Three Tiers)

- **Tier 1 — Simple packages:** No config needed → add to category's `default.nix` under `home.packages`
- **Tier 2 — Has HM module:** Own `.nix` file with `mkAliasOptionModule` mapping `internal.<path>` → `programs.<name>`, plus defaults
- **Tier 3 — Config-only:** No HM module but needs config → own `.nix` file with custom options, writes config via `xdg.configFile` / `dconf.settings`

# Verification

- Standalone home config build does NOT work with Snowfall Lib (`nix build .#homeConfigurations.mrbandler@zeus` fails with type error)
- Use `nix flake check` (or `just check`) to validate the full flake
- For full system build (includes home-manager): `nix build .#nixosConfigurations.zeus.config.system.build.toplevel` (or `just build`)
