# Arch Installation Guide for Me

## Disclaimer

Always check the latest installation guide, in case of changes.

## Guide

Change the keyboard layout

```
$ loadkeys fi
```

Verify the boot mode

```
$ cat /sys/firmware/efi/fw_platform_size
```

64 = Booted in UEFI mode
32 = Booted in UEFI mode 32-bit IA32

32-bit is supported but limits the boot loader of choice to systemd-boot and GRUB

Connect to internet either by using ethernet cable or connecting to wifi

possibly useful commands:

```
$ iwctl
$ dhcpcd
$ ping
```

Update the system clock using `timedatectl`

```
$ timedatectl
```

Partition the disk using `fdisk` (TODO: add instructions how to encrypt disk)

```
$ fdisk -l
```

Select the disk to partition. (Select the disk that doesn't have appending 1,2, etc.)

```
$ fdisk nvme0n1
```

Create UEFI partition

```
n
1
+512M
t
1
uefi
```

Create boot partition

```
n
2
<enter>
q
```

Create UEFI file system on the first partition

```
$ mkfs.fat -F32 /dev/nvme0n1p1
```

Create Ext4 filesystem on the root partition

```
$ mfks.ext4 /dev/nvme0n1p2
```

Sync repositories and install reflector (don't use `pacman -Syy`, like some guides do, it can be dangerous). Reflector is used to get best mirrors for your location.

```
$ pacman -Sy reflector
```

Create backup of mirrors

```
$ cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
```

Update mirrors

```
$ reflector -c "FI" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
```

Mount to the root

```
$ mount /dev/nvme0n1p2 /mnt
```

Install necessary packages to the new system

```
$ pacstrap /mnt base linux linux-firmware vim iwd dhcpcd git man-db man-pages texinfo
```

Generate fstab

```
$ genfstab -U /mnt >> /mnt/etc/fstab
```

Change root to the new system root

```
$ arch-chroot /mnt
```

Set time

```
$ ln -sf /usr/share/zoneinfo/Europe/Helsinki /etc/localtime
```

Sync hardware clock

```
$ hwclock --systohc
```

Select localization by uncommenting localizations from /etc/locale.gen

```
$ vim /etc/locale.gen
$ locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
```

Select hostname

```
echo my_hostname > /etc/hostname
```

Basic /etc/hosts configuration

```
$ vim /etc/hosts
127.0.0.1 localhost
::1       localhost
```

Create new initramfs (shouldn't be necessary but just in case)

```
$ mkinitcpio -P
```

Change root password

```
$ passwd
```

Install GRUB and create boot partition

```
$ pacman -S grub efibootmgr
$ mkdir /boot/efi
$ mount /dev/nvme0n1p1 /boot/efi
$ grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
$ grub-mkconfig -o /boot/grub/grub.cfg
```

Create new sudo user

```
$ pacman -S sudo
$ useradd -m my_user
$ passwd my_user
$ usermod -aG wheel,audio,video,storage my_user
$ visudo
uncomment
%wheel ALL=(ALL:ALL) ALL
```

Quit the chroot and boot to the new system

```
$ exit
$ reboot
```

## After installation

Check locales (output might differ a bit but LANG should be en_US.UTF-8, some applications might not work correctly if it's "C", though sometimes the LANG=C is used for debugging...)

```
$ localectl
System Locale: LANG=en_US.UTF-8
    VC Keymap: fi
   X11 Layout: fi
    X11 Model: pc105
  X11 Options: terminate:ctrl_alt_bksp
```

Enable & start systemd-timesyncd

```
$ sudo systemctl enable systemd-timesyncd
$ sudo systemctl start systemd-timesyncd
```

Check that time is correct

```
$ timedatectl
```

(optional)
If you have windows dualboot you might want to change RTC (real-time clock) to use local time. This is because Windows automatic time sync isn't actually automatic...

```
$ timedatectl set-local-rtc 1
```

# Debugging

## Long Bootup Time

If you didn't setup disk encryption and are noticing a long time for system boot check if TPM (Trusted Platform Module) is causing the delay

```
$ sudo journalctl -k --grep=tpm
```

Disable tpm in bios if not in use e.g., dualboot.

## Audio Device Doesn't Resume After Idle

If having audio problems that get fixed by reselecting the audio profile from pavucontrol, or using pulseaudio.

```
$ pacmd set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo
$ pacmd set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
```

Try commenting out `load-module module-suspend-on-idle` from `/etc/pulse/default.pa`
