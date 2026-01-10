git clone --bare https://github.com/Paippi/dotfiles.git $HOME/.dotcfg
function config {
    /usr/bin/git --git-dir=$HOME/.dotcfg --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no
config config user.name "Samuli Piippo"
config config user.email "28383147+Paippi@users.noreply.github.com"

echo "Setting up ssh keys"
ssh-keygen

echo "Changing remote to ssh"
config remote set-url origin $(config remote -v | sed 's/https:\/\//git@/' | \
    sed 's/\//:/' | awk -F ' ' '{print $2}' | head -n 1)
