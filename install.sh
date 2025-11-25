parted /dev/nvme0n1 << EOF
mklabel gpt
mkpart primary fat32 1MiB 513MiB
set 1 esp on
name 1 EFI
mkpart primary linux-swap 513MiB 65GiB
name 2 swap
mkpart primary ext4 65GiB 100%
name 3 root
quit
EOF
mkfs.vfat -F 32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3
mkdir --parents /mnt/gentoo
mount /dev/nvme0n1p3 /mnt/gentoo
mkdir --parents /mnt/gentoo/efi
mount /dev/nvme0n1p1 /mnt/gentoo/efi
wget --directory-prefix=/mnt/gentoo https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-musl/$(curl --silent https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-musl/latest-stage3-amd64-musl.txt | grep --only-matching '.*.tar.xz')
tar xpvf /mnt/gentoo/*.tar.xz --xattrs-include='*.*' --numeric-owner --directory=/mnt/gentoo
rm --force /mnt/gentoo/*.tar.xz
cp --recursive ./root/* /mnt/gentoo/
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
arch-chroot /mnt/gentoo /bin/bash -c 'emerge-webrsync'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge --sync'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge --verbose --update --deep --newuse @world'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge sys-kernel/linux-firmware'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge sys-kernel/gentoo-kernel-bin'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge sys-libs/timezone-data'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge sys-apps/musl-locales'
arch-chroot /mnt/gentoo /bin/bash -c 'env-update && source /etc/profile'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge net-wireless/iwd'
arch-chroot /mnt/gentoo /bin/bash -c 'rc-update add iwd default'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge net-misc/dhcpcd'
arch-chroot /mnt/gentoo /bin/bash -c 'rc-update add dhcpcd default'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge app-admin/sysklogd'
arch-chroot /mnt/gentoo /bin/bash -c 'rc-update add sysklogd default'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge net-misc/chrony'
arch-chroot /mnt/gentoo /bin/bash -c 'rc-update add chronyd default'
arch-chroot /mnt/gentoo /bin/bash -c 'echo "root:chaoschead" | chpasswd'
arch-chroot /mnt/gentoo /bin/bash -c 'useradd -m -G users,wheel,audio -s /bin/bash lain'
arch-chroot /mnt/gentoo /bin/bash -c 'echo "lain:chaoschead" | chpasswd'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge sys-fs/genfstab'
arch-chroot /mnt/gentoo /bin/bash -c 'genfstab -U / >> /etc/fstab'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge sys-boot/grub'
arch-chroot /mnt/gentoo /bin/bash -c 'grub-install --efi-directory=/efi'
arch-chroot /mnt/gentoo /bin/bash -c 'grub-mkconfig -o /boot/grub/grub.cfg'
arch-chroot /mnt/gentoo /bin/bash -c 'rc-update add elogind boot'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge app-admin/doas'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge dev-vcs/git'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge app-misc/neofetch'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge dev-libs/wayland'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge gui-wm/sway'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge gui-apps/swaybg'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge gui-apps/waybar'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge gui-apps/foot'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge gui-apps/grim'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge gui-apps/wl-clipboard'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge app-editors/neovim'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge www-client/qutebrowser'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge media-sound/pulsemixer'
arch-chroot /mnt/gentoo /bin/bash -c 'emerge net-vpn/i2pd'
arch-chroot /mnt/gentoo /bin/bash -c 'rc-update add i2pd default'1
arch-chroot /mnt/gentoo /bin/bash -c 'emerge --pretend --depclean'
umount --recursive /mnt/gentoo/
