# Git

- Conventional Commits with hierarchical scopes: `type(nix/scope): message`
- No "Co-Authored-By", "Generated with [tool]", or any AI attribution in commits
- Don't commit `docs/` — keep plans and specs local only
- No intermediate commits — only commit once all changes build and work, and always ask before committing
- Always create atomic commits — each commit should be a single logical change

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
- Snowfall auto-imports subdirectories with `default.nix` — don't add explicit imports for them in the parent (causes duplicate option declarations)
- Namespace follows directory path: `internal.<domain>.<sub>.<module>`

## Module Creation Rules (Three Tiers)

- **Tier 1 — Simple packages:** No config needed → add to category's `default.nix` under `home.packages`
- **Tier 2 — Has HM module:** Own `.nix` file with `mkAliasOptionModule` mapping `internal.<path>` → `programs.<name>`, plus defaults
- **Tier 3 — Config-only:** No HM module but needs config → own `.nix` file with custom options, writes config via `xdg.configFile` / `dconf.settings`

## Config File Placement

- When a module has static (non-Nix-interpolated) config files written as inline multi-line strings, extract them as actual files next to `default.nix`
- Single config file → place alongside `default.nix` in a directory named after the tool (e.g., `diffnav/default.nix` + `diffnav/config.yml`)
- Multiple config files → use a `config/` subdirectory (e.g., `neovim/default.nix` + `neovim/config/`)
- Use read-only `xdg.configFile."...".source` by default — only use mutable `home.activation` copy pattern when the tool genuinely needs to write to its own config at runtime
- Config generated via Nix (`yamlFormat.generate`, `tomlFormat.generate`, Nix interpolation) stays in the `.nix` file

# Verification

- Standalone home config build does NOT work with Snowfall Lib (`nix build .#homeConfigurations.mrbandler@zeus` fails with type error)
- Use `nix flake check` (or `just check`) to validate the full flake
- For full system build (includes home-manager): `nix build .#nixosConfigurations.zeus.config.system.build.toplevel` (or `just build`)
