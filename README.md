```
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

My personal dotfiles, primarily NixOS with home-manager.

## NixOS

```bash
# Clone and enter
git clone https://github.com/mrbandler/dotfiles ~/.dotfiles
cd ~/.dotfiles/nix

# Build and switch (replace <host> with your hostname)
sudo nixos-rebuild switch --flake .#<host>
```

### Hosts

| Host | Description |
|------|-------------|
| `zeus` | Main workstation |
| `ade` | (unmaintained) |

## Legacy

### Windows (abandoned)

The `chezmoi/` directory contains Windows configuration via [chezmoi](https://chezmoi.io/). No longer maintained.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply mrbandler"
```
