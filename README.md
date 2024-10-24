# Arch installation

1. Follow instructions in arch_install_guide.md
2. run `$ curl -Lks https://github.com/Paippi/dotfiles/setup_dotfiles.sh | /bin/bash`
3. run `$ bash arch_setup_install.sh`

## Keeping track of configuration changes

`config` is alias for `git` with some configuration changes. Use like git.

```
$ config add <my file>
$ config commit -m "Added <my file>"
$ config push origin main
$ config add -u # Will stage the modified and deleted files
$ config commit -a # Will commit only the modified and deleted files
```
