#!/bin/bash

set -e
#set -ex

declare -r boot_img_url='http://d-i.debian.org/daily-images/amd64/daily/hd-media/boot.img.gz'
declare -r boot_img_sha256='9302c81b56283e2374049ac471806bef3126a46b8f79b2e7e1e307619ccdb819'
declare -r boot_img_gz="${boot_img_url##*/}"
declare -r boot_img="${boot_img_gz%.*}"

declare -r install_cd1_url='http://cdimage.debian.org/debian-cd/8.0.0/amd64/iso-cd/debian-8.0.0-amd64-kde-CD-1.iso'
declare -r install_cd1_sha256='6f949274408d253e8c544fe4e66a3614098298b1deaa0de74ee30b3b3487f5fe'
declare -r install_cd1="${install_cd1_url##*/}"

declare -r firmware_url='http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/jessie/current/firmware.tar.gz'
declare -r firmware="${firmware_url##*/}"

declare -r mnt_point='/mnt/usbstick'

declare -r wrap_cmd=()
#declare -r wrap_cmd=(':')       # Dry run
#declare -r wrap_cmd=('echo')    # Dry run, but print commands

wrap()
{
    "${wrap_cmd[@]}" "$@"
}

sudo_wrap()
{
    wrap sudo "$@"
}

main()
{
    local -r progName="$1"; shift

    if (( $# == 0 )); then
        echo "${0##*/} DEVICE"
        exit 1
    else
        local -r device="$1"; shift
    fi

    # {{{ Create Bootable USB Dongle
    if [[ ! -e "$boot_img" ]]; then
        if [[ ! -e "$boot_img_gz" ]]; then
            # If this failed because of unrecognized "download" command, then
            # download it from:
            #
            # https://github.com/trskop/snippets/raw/master/scripts/download.sh
            wrap download --sha256="$boot_img_sha256" "$boot_img_url" || exit 2
        fi
        wrap gunzip --keep "$boot_img_gz"
    fi

    # Device will be most likely mounted. If this failed, because your USB
    # dongle doesn't mount automatically then just comment out following line.
    sudo_wrap umount "$device"

    sudo_wrap dd if="$boot_img" of="$device" bs=4M
    wrap sync
    sudo_wrap blockdev --rereadpt "$device"
    # }}} Create Bootable USB Dongle

    # {{{ Mount USB Dongle
    if [[ ! -e "$mnt_point" ]]; then
        sudo_wrap mkdir "$mnt_point"
    fi
    sudo_wrap mount "$device" "$mnt_point"
    # }}} Mount USB Dongle

    # {{{ Debian Install CD1
    if [[ ! -e "$install_cd1" ]]; then
        wrap download --sha256="$install_cd1_sha256" "$install_cd1_url"
    fi
    sudo_wrap cp "$install_cd1" "$mnt_point"
    # }}} Debian Install CD1

    # {{{ Add Non-free Firmware to USB Dongle
    if [[ ! -e "$firmware" ]]; then
        wrap download "$firmware_url"
    fi
    sudo_wrap cp "$firmware" "$mnt_point"
    sudo_wrap tar -C "$mnt_point" -xf "$firmware"
    # }}} Add Non-free Firmware to USB Dongle

    # {{{ Umount USB Dongle
    wrap sync
    sudo_wrap umount "$device"
    # {{{ Umount USB Dongle
}

main "${0##*/}" "$@"
