# shellcheck shell=bash

export BOARD_NAME="Fmx1 Pro"
export BOARD_MAKER="Rockchip"
export BOARD_SOC="Rockchip RK3399"
export BOARD_CPU="ARM Cortex A72 / A53"
export UBOOT_PACKAGE="u-boot-rk3399"
export UBOOT_RULES_TARGET="fmx1-pro-rk3399"
export COMPATIBLE_SUITES=("jammy" "noble")
export COMPATIBLE_FLAVORS=("server" "desktop")

function config_image_hook__fmx1-pro() {
    local rootfs="$1"
    local suite="$3"

    if [ "${suite}" == "jammy" ] || [ "${suite}" == "noble" ]; then
        # Install panfork
        chroot "${rootfs}" add-apt-repository -y ppa:jjriek/panfork-mesa
        chroot "${rootfs}" apt-get update
        chroot "${rootfs}" apt-get -y install mali-t860-firmware
        chroot "${rootfs}" apt-get -y dist-upgrade

        # Install libmali blobs alongside panfork
        chroot "${rootfs}" apt-get -y install libmali-t860-x11
    fi

    return 0
}
