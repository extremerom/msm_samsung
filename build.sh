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

#1. target config
# pa1q_eur_open_user
export MODEL="pa1q"
export PROJECT_NAME=${MODEL}
export REGION="eur"
export CARRIER="open"
export TARGET_BUILD_VARIANT="user"
		
		
#2. sm8750 common config
CHIPSET_NAME="sm8750"

export ANDROID_BUILD_TOP=${WDIR}
export TARGET_PRODUCT=perf
export TARGET_BOARD_PLATFORM=gki

export ANDROID_PRODUCT_OUT=${ANDROID_BUILD_TOP}/out/target/product/${MODEL}
export OUT_DIR=${ANDROID_BUILD_TOP}/out/msm-${CHIPSET_NAME}-${CHIPSET_NAME}-${TARGET_PRODUCT}

# for Lcd(techpack) driver build
export KBUILD_EXTRA_SYMBOLS=${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mmrm-driver/Module.symvers

# for Audio(techpack) driver build
export MODNAME=audio_dlkm

export KBUILD_EXT_MODULES="\
	../vendor/qcom/opensource/mmrm-driver \
        ../vendor/qcom/opensource/mm-drivers/msm_ext_display \
        ../vendor/qcom/opensource/mm-drivers/sync_fence \
        ../vendor/qcom/opensource/mm-drivers/hw_fence \
        ../vendor/qcom/opensource/securemsm-kernel \
        "

# custom build options
export GKI_BUILDSCRIPT="./build/android/prepare_vendor.sh"
export BUILD_OPTIONS=(
    RECOMPILE_KERNEL=1
    SKIP_MRPROPER=1
)

#3. build kernel
build_kernel(){
    cd ${WDIR}/kernel_platform && \
        env ${BUILD_OPTIONS[@]} ${GKI_BUILDSCRIPT} ${CHIPSET_NAME} ${TARGET_PRODUCT} gki && \
        cd ${WDIR}
}

build_kernel
