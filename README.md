# dotfiles

**My personal dotfiles that I use across all my machines (🐧 &amp;&amp; 🪟)**

## 📥 Installation

The following one-liners will download and install [`chezmoi`](https://chezmoi.io/), and initialize it with this repository.

> ⚠️ **WARNING: WILL MODIFIY YOUR SYSTEM!**

### 🪟 Windows

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply mrbandler"
```

### 🐧 Linux

```bash
sh -c "$(curl -fsLS get.chezmoi.io) -- init --apply mrbandler"
```

### ❄️ NixOS

```bash
Coming soon...
```

## ✅ To-Do's

### 🪟 Windows

- [x] Boostrapping
- [ ] DSC-based State Configuration
  - [x] Debloat
  - [ ] Settings
  - [x] Package Management (Download & Install, winget, choco, scoop)
- [ ] Configuration Files
- [ ] Secret Management

### 🐧 Linux

**_TBD_**

### ❄️ Nix

**_TBD_**
