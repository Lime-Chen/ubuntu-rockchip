# shellcheck shell=bash

export BOARD_NAME="Toybrick D0"
export BOARD_MAKER="Toybrick"
export BOARD_SOC="Rockchip RK3588S"
export BOARD_CPU="ARM Cortex A76 / A55"
export UBOOT_PACKAGE="u-boot-radxa-rk3588"
export UBOOT_RULES_TARGET="toybrick-d0-rk3588s"
export COMPATIBLE_SUITES=("jammy")
export COMPATIBLE_FLAVORS=("server" "desktop")

function config_image_hook__toybrick-d0() {
    local rootfs="$1"
    local overlay="$2"
    local suite="$3"

    if [ "${suite}" == "jammy" ] || [ "${suite}" == "noble" ]; then
        # Install panfork
        chroot "${rootfs}" add-apt-repository -y ppa:jjriek/panfork-mesa
        chroot "${rootfs}" apt-get update
        chroot "${rootfs}" apt-get -y install mali-g610-firmware
        chroot "${rootfs}" apt-get -y dist-upgrade

        # Install libmali blobs alongside panfork
        chroot "${rootfs}" apt-get -y install libmali-g610-x11

        # Install the rockchip camera engine
        chroot "${rootfs}" apt-get -y install camera-engine-rkaiq-rk3588
        
        # Add install wifi ap6255
        mkdir -p "${rootfs}/usr/lib/firmware"
        cp -r "${overlay}/usr/lib/firmware/ap6255" "${rootfs}/usr/lib/firmware/"
    fi

    return 0
}
