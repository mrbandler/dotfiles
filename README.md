```
       _     _    __ _ _
    __| |___| |_ / _(_) |___ ___
  _/ _` / _ \  _|  _| | / -_|_-<
 (_)__,_\___/\__|_| |_|_\___/__/
```

**My personal dotfiles, managed with a bare git repository.**

## Dotfiles Installation

> NOTE: For more details please read the excellent article about this method [here](https://www.atlassian.com/git/tutorials/dotfiles).

To check out my `.dotfiles` use the following commands:

```console
git clone --bare https://github.com/mrbandler/dotfiles $HOME/.dotfiles
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout
```
