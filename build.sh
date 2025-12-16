#!/bin/bash

export WDIR="$(dirname $(readlink -f $0))" && cd "$WDIR"

# Download and install Toolchain
if [ ! -d "${WDIR}/kernel_platform/prebuilts" ]; then
    echo -e "[+] Downloading and installing Toolchain...\n"
    sudo apt install rsync p7zip-full curl tar -y
    curl -L --progress-bar -o "toolchain.tar.gz" "https://www.dropbox.com/scl/fi/mugzq17bjgonj9jqsvsq1/toolchain.tar.gz?rlkey=ebchnfs8pmezl92kzlg9clrmg&st=rdtael0w&dl=1"
    tar -xzf toolchain.tar.gz && rm toolchain.tar.gz
    chmod -R +x "${WDIR}/kernel_platform/prebuilts"    
fi

echo -e "[+] Toolchain installed...\n"

# Setup custom config symlinks for kernel build
# The Image is built from common kernel, and msm-kernel builds modules
# Both need access to the custom config to stay in sync
if [ -f "${WDIR}/custom_defconfigs/custom.config" ]; then
    if [ ! -f "${WDIR}/kernel_platform/common/custom.config" ]; then
        echo -e "[+] Creating symlink for custom config in common/...\n"
        ln -sf ../../custom_defconfigs/custom.config "${WDIR}/kernel_platform/common/custom.config"
    fi
    if [ ! -f "${WDIR}/kernel_platform/msm-kernel/custom.config" ]; then
        echo -e "[+] Creating symlink for custom config in msm-kernel/...\n"
        ln -sf ../../custom_defconfigs/custom.config "${WDIR}/kernel_platform/msm-kernel/custom.config"
    fi
fi

#1. target config
# pa1q_eur_open_user
export MODEL="dm2q"
export PROJECT_NAME=${MODEL}
export REGION="eur"
export CARRIER="openx"
export TARGET_BUILD_VARIANT="user"
		
		
#2. kalama (sm8550) common config
CHIPSET_NAME="kalama"

export ANDROID_BUILD_TOP=${WDIR}
export TARGET_PRODUCT=gki
export TARGET_BOARD_PLATFORM=gki

export ANDROID_PRODUCT_OUT=${ANDROID_BUILD_TOP}/out/target/product/${MODEL}
export OUT_DIR=${ANDROID_BUILD_TOP}/out/msm-${CHIPSET_NAME}-${CHIPSET_NAME}-${TARGET_PRODUCT}

# for Lcd(techpack) driver build
export KBUILD_EXTRA_SYMBOLS="${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mmrm-driver/Module.symvers \
		${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mm-drivers/hw_fence/Module.symvers \
		${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mm-drivers/sync_fence/Module.symvers \
		${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mm-drivers/msm_ext_display/Module.symvers \
		${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/securemsm-kernel/Module.symvers \
"

# for Audio(techpack) driver build
export MODNAME=audio_dlkm

export KBUILD_EXT_MODULES="../vendor/qcom/opensource/mm-drivers/msm_ext_display \
  ../vendor/qcom/opensource/mm-drivers/sync_fence \
  ../vendor/qcom/opensource/mm-drivers/hw_fence \
  ../vendor/qcom/opensource/mmrm-driver \
  ../vendor/qcom/opensource/securemsm-kernel \
  ../vendor/qcom/opensource/display-drivers/msm \
  ../vendor/qcom/opensource/audio-kernel \
  ../vendor/qcom/opensource/camera-kernel \
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
        env ${BUILD_OPTIONS[@]} ${GKI_BUILDSCRIPT} ${CHIPSET_NAME} ${TARGET_PRODUCT} && \
        cd ${WDIR}
}

build_kernel
