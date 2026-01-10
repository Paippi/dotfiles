yay -Syu --no-confirm nvidia-580xx-dkms nvidia-580xx-settings nvidia-580xx-utils lib32-nvidia-580xx-utils

sudo chown root:root $HOME/.system-config/nvidia-mkinitcpio.conf
sudo chmod 0644 $HOME/.system-config/nvidia-mkinitcpio.conf
sudo ln -s $HOME/.system-config/nvidia-mkinitcpio.conf /etc/mkinitcpio.conf

sudo chown root:root $HOME/.system-config/no-nouveau.conf
sudo chmod 0644 $HOME/.system-config/no-nouveau.conf
sudo ln -s $HOME/.system-config/no-nouveau.conf /etc/modprobe.d/

# Blacklist using a kernel option, because as the time being blacklisting in
# /etc/modprobe.d/ doesn't work
echo "options module_blacklist=nouveau" | sudo tee -a /boot/loader/entries/arch.conf 1>/dev/null
