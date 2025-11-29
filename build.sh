#!/bin/bash

export WDIR="$(dirname $(readlink -f $0))" && cd "$WDIR"

# Download and install Toolchain
if [ ! -d "${WDIR}/kernel_platform/prebuilts" ]; then
    echo -e "[+] Downloading and installing Toolchain...\n"
    sudo apt install rsync p7zip-full -y
    curl -LO --progress-bar https://github.com/ravindu644/-android_kernel_sm_s931b/releases/download/toolchain/qcom-6.6-toolchain.tar.gz.zip
    curl -LO --progress-bar https://github.com/ravindu644/-android_kernel_sm_s931b/releases/download/toolchain/qcom-6.6-toolchain.tar.gz.z01
    7z x qcom-6.6-toolchain.tar.gz.zip && rm qcom-6.6-toolchain.tar.gz.zip qcom-6.6-toolchain.tar.gz.z01
    tar -xvf qcom-6.6-toolchain.tar.gz && rm qcom-6.6-toolchain.tar.gz
    chmod -R +x "${WDIR}/kernel_platform/prebuilts"    
fi

echo -e "[+] Toolchain installed...\n"
