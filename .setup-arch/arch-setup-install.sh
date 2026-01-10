#!/usr/bin/env bash
set -ex
sudo systemctl enable --now dhcpcd
echo "Temporarily disabling IPv6, because some mirrors don't work 100% of the time when IPv6 is enabled..."
sudo systctl -w net.ipv6.conf.all.disable_ipv6=1

echo "Enable mirrors"
sudo chown root:root $HOME/.system-config/pacman.conf
sudo chmod 0644 $HOME/.system-config/pacman.conf
sudo ln -s $HOME/.system-config/pacman.conf /etc/pacman.conf

echo "Disable pc speaker + beep"
sudo chown root:root $HOME/.system-config/no-beep.conf
sudo chmod 0644 $HOME/.system-config/no-beep.conf

echo "Downloading basic programs..."
sudo pacman --noconfirm -Syu xorg xorg-xinit rofi i3 htop unzip neovim picom   \
    base base-devel feh alsa-utils pavucontrol rxvt-unicode python             \
    python-pipenv git curl pulseaudio wget xclip firefox spotify-launcher      \
    ranger pyenv ttf-bitstream-vera ttf-font-awesome urxvt-perls ctags nodejs  \
    npm telegram-desktop powerline powerline-fonts sysstat iw acpi xcape       \
    ttf-sourcecodepro-nerd iwd dhcpcd openssh systemd-resolvconf imagemagick   \
    python-pynvim python-jedi zsh util-linux linux-headers dkms

# Basic networking setup. Systemd-networkd is required for systemd-resolved, which will
# manage dns settings... This isn't absolutely required, but services like VPN might not
# work without it.
systemctl enable --now systemd-networkd
systemctl enable --now systemd-resolved

# Enable periodic TRIM for SSDs for performance improvements.
systemctl enable --now fstrim.timer

echo "Setting up yay"
# Install 3rdparty libraries here that cannot be installed using package manager.
mkdir $HOME/3rdparty
pushd $HOME/3rdparty

git clone https://aur.archlinux.org/yay.git
pushd yay
makepkg -si
popd

popd

echo "Downloading packages using yay..."

yay -S urxvt-resize-font-git
yay -S ttf-yosemite-san-francisco-font-git
yay -S discord

echo "Install oh-my-zsh..."
# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv $HOME/.zshrc.pre-oh-my-zsh $HOME/.zshrc

echo "Installing vim plugin manager Vundle..."
mkdir --parent $HOME/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim

echo "Installing rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo "Creating swap file, this is not necessary if using swap partition"
sudo mkswap -U clear --size 4G --file /swapfile
sudo swapon /swapfile
sudo bash -c "echo '/swapfile none swap defaults 0 0' >> /etc/fstab"

echo "Setup automatic time sync..."
sudo systemctl enable systemd-timesyncd.service
sudo systemctl start systemd-timesyncd.service

echo "Configuring locales..."
sudo localectl set-x11-keymap fi
sudo localectl set-locale LANG=en_US.UTF-8
sudo localectl set-keymap fi
sudo locale-gen

echo "Installing vim dependencies..."
vim -c ':PluginInstall' -c 'qa!'
pushd $HOME/.vim/bundle/command-t/lua/wincent/commandt/lib
make
pushd $HOME/.vim/bundle/coc.nvim
npm ci
popd
popd
echo "Installing CoC Addons..."
echo "You might need to install these manually if vim exits before waiting for the downloads to finish..."
vim -c ':CocInstall coc-rust-analyzer coc-pyright coc-json coc-tsserver coc-toml' -c 'qa!'

echo "Setup i3blocks..."
git clone https://github.com/vivien/i3blocks-contrib $HOME/.config/i3blocks
envsubst '${HOME}' < $HOME/.config_templates/i3blocks_config > $HOME/.config/i3blocks/config

echo "Setup rofi..."
envsubst '${HOME}' < $HOME/.config_templates/config.rasi > $HOME/.config/rofi/config.rasi

# TODO: automate
echo "From Firefox set tab auto close off"
echo "about:config -> browser.fullscreen.autohide = false"

echo "Install CPU hardware bug and security fixes"
echo "Depending on your CPU either install amd-ucode or intel-ucode"

echo "If using windows dualboot you might want to set RTC to use local time."
echo "$ timedatectl set-local-rtc 1"

echo "Re-enable ipv6"
sudo systctl -w net.ipv6.conf.all.disable_ipv6=0
