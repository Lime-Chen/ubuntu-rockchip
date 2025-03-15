#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

cd "$(dirname -- "$(readlink -f -- "$0")")" && cd ..
mkdir -p build && cd build

if [[ -z ${SUITE} ]]; then
    echo "Error: SUITE is not set"
    exit 1
fi

# shellcheck source=/dev/null
source "../config/suites/${SUITE}.sh"
source "../build/linux-rockchip/debian/debian.env"

# Clone the kernel repo
if ! git -C linux-rockchip pull; then
    git clone --progress -b "${KERNEL_BRANCH}" "${KERNEL_REPO}" linux-rockchip --depth=2
fi

cd linux-rockchip
git checkout "${KERNEL_BRANCH}"

# shellcheck disable=SC2046
export $(dpkg-architecture -aarm64)
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
# 注意这里直接拼接 CROSS_COMPILE 和 gcc 来形成完整的交叉编译器路径
export CC=${CROSS_COMPILE}gcc
export LANG=C

# 调试输出
echo "ARCH is set to $ARCH"
echo "CROSS_COMPILE is set to $CROSS_COMPILE"
echo "CC is set to $CC"

# 测试交叉编译器
${CC} --version

# Compile the kernel into a deb package
# fakeroot debian/rules clean binary-headers binary-rockchip do_mainline_build=true
# 编译内核为deb包时确保使用正确的环境变量
DEB_BUILD_OPTIONS="crossbuild-arch=${ARCH}" fakeroot debian/rules clean binary-headers binary-rockchip do_mainline_build=true
