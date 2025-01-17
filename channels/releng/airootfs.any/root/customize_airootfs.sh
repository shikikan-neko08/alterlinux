#!/usr/bin/env bash
#
# Yamada Hayao
# Twitter: @Hayao0819
# Email  : hayao@fascode.net
#
# (c) 2019-2021 Fascode Network.
#

set -e -u


# Default value
# All values can be changed by arguments.
password=alter
boot_splash=false
kernel_config_line=("zen" "vmlinuz-linux-zen" "linux-zen")
theme_name=alter-logo
username='alter'
os_name="Alter Linux"
install_dir="alter"
usershell="/bin/bash"
debug=false
timezone="UTC"
localegen="en_US\\.UTF-8\\"
language="en"


# Parse arguments
while getopts 'p:bt:k:xu:o:i:s:da:g:z:l:' arg; do
    case "${arg}" in
        p) password="${OPTARG}" ;;
        b) boot_splash=true ;;
        t) theme_name="${OPTARG}" ;;
        #k) kernel_config_line=(${OPTARG}) ;;
        k) IFS=" " read -r -a kernel_config_line <<< "${OPTARG}" ;;
        u) username="${OPTARG}" ;;
        o) os_name="${OPTARG}" ;;
        i) install_dir="${OPTARG}" ;;
        s) usershell="${OPTARG}" ;;
        d) debug=true ;;
        x) debug=true; set -xv ;;
        a) arch="${OPTARG}" ;;
        g) localegen="${OPTARG/./\\.}\\" ;;
        z) timezone="${OPTARG}" ;;
        l) language="${OPTARG}" ;;
        *) : ;;
    esac
done


# Parse kernel
kernel="${kernel_config_line[0]}"
kernel_filename="${kernel_config_line[1]}"
kernel_mkinitcpio_profile="${kernel_config_line[2]}"


# Show message when file is removed
# remove <file> <file> ...
remove() {
    local _file
    for _file in "${@}"; do echo "Removing ${_file}"; rm -rf "${_file}"; done
}


remove /etc/skel/Desktop
remove /root/Desktop

if [[ "${arch}" = "i686" ]]; then
    ln -s /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist32
fi

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# Enable services.
systemctl enable NetworkManager
systemctl enable pacman-init.service
systemctl enable alteriso-reflector.service
systemctl disable reflector.service
systemctl set-default multi-user.target

remove /etc/arch-release
touch /etc/arch-release

remove "/etc/plymouth"
remove "/usr/share/calamares"
remove "/home/hayao/Git/alterlinux/channels/share/airootfs.any/etc/polkit-1/rules.d/01-nopasswork.rules"
remove "/home/hayao/Git/alterlinux/channels/share/airootfs.any/etc/polkit-1/rules.d/10-enable-mount.rules"
