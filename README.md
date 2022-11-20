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

For convinience please add these aliases to the respective profiles:

```bash
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

```powershell
function config {
    $params = @("--git-dir=$HOME\.dotfiles", "--work-tree=$HOME")
    $params += $args

    for ($i = 0; $i -lt $params.count; $i++)
    {
        $param = $params[$i]
        if (($param -replace "[^\s]").length -gt 0) { $params[$i] = "`"$param`"" }
    }

    Start-Process -NoNewWindow -FilePath $(where.exe git) -ArgumentList $params -Wait
}
```

After that you can use `config` (which expands to `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`):

```console
config status
config add profile.ps1
config commit -m "Added new configuration files"
config pull
config push
```
