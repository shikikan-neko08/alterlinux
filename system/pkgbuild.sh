#!/usr/bin/env bash
#
# Yamada Hayao
# Twitter: @Hayao0819
# Email  : hayao@fascode.net
#
# (c) 2019-2021 Fascode Network.
#
set -e

build_username="pkgbuild"


# Delete file only if file exists
# remove <file1> <file2> ...
function remove () {
    local _list
    local _file
    _list=($(echo "$@"))
    for _file in "${_list[@]}"; do
        if [[ -f ${_file} ]]; then
            rm -f "${_file}"
        elif [[ -d ${_file} ]]; then
            rm -rf "${_file}"
        fi
        echo "${_file} was deleted."
    done
}

# user_check <name>
function user_check () {
    if [[ ! -v 1 ]]; then return 2; fi
    getent passwd "${1}" > /dev/null
}

# 一般ユーザーで実行します
function run_user () {
    sudo -u "${build_username}" ${@}
}

# 引数を確認
if [[ -z "${1}" ]]; then
    echo "Please specify the directory that contains PKGBUILD." >&2
    exit 1
else
    pkgbuild_dir="${1}"
fi

# Creating a user for makepkg
if ! user_check "${build_username}"; then
    useradd -m -d "${pkgbuild_dir}" "${build_username}"
fi
mkdir -p "${pkgbuild_dir}"
chmod 700 -R "${pkgbuild_dir}"
chown -R "${build_username}" "${pkgbuild_dir}"
echo "${build_username} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/pkgbuild"

# Setup keyring
pacman-key --init
pacman-key --populate

# Un comment the mirror list.
#sed -i "s/#Server/Server/g" "/etc/pacman.d/mirrorlist"

# Update datebase
pacman -Syy --config "/etc/alteriso-pacman.conf"

# Parse SRCINFO
cd "${pkgbuild_dir}"
pkgbuild_dirs=($(ls "${pkgbuild_dir}" 2> /dev/null))
if (( "${#pkgbuild_dirs[@]}" != 0 )); then
    for _dir in ${pkgbuild_dirs[@]}; do
        cd "${_dir}"
        depends=($(source "${pkgbuild_dir}/${_dir}/PKGBUILD"; echo "${depends[@]}"))
        makedepends=($(source "${pkgbuild_dir}/${_dir}/PKGBUILD"; echo "${makedepends[@]}"))
        if (( ${#depends[@]} + ${#makedepends[@]} != 0 )); then
            for _pkg in ${depends[@]} ${makedepends[@]}; do
                if pacman -Ssq "${_pkg}" | grep -x "${_pkg}" 1> /dev/null; then
                    pacman -S --config "/etc/alteriso-pacman.conf" --noconfirm --asdeps --needed "${_pkg}"
                fi
            done
        fi
        run_user makepkg -iAcCs --noconfirm --skippgpcheck 
        cd - >/dev/null
    done
fi

if deletepkg=($(pacman -Qtdq)) &&  (( "${#deletepkg[@]}" != 0 )); then
    pacman -Rsnc --noconfirm "${deletepkg[@]}" --config "/etc/alteriso-pacman.conf"
fi

pacman -Sccc --noconfirm --config "/etc/alteriso-pacman.conf"

# remove user and file
userdel "${build_username}"
remove "${pkgbuild_dir}"
remove "/etc/sudoers.d/pkgbuild"
remove "/etc/alteriso-pacman.conf"
remove "/var/cache/pacman/pkg/"
