# Install CLI.
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod get.scoop.sh | Invoke-Expression

# Add buckets.
scoop bucket add main
scoop bucket add extras
scoop bucket add versions
scoop bucket add nerd-fonts

# Install packages.
scoop install sudo
scoop install llvm
scoop install rustup
scoop install haskell
scoop install haskell-cabal
scoop install stack
scoop install nvm
scoop install vivetool
scoop install blender-launcher
scoop install emacs
scoop install neovim
scoop install gh
scoop install colortool

# GitHub CLI.
gh extension install redraw/gh-install
gh install
