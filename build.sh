#!/bin/bash

export WDIR="$(dirname $(readlink -f $0))" && cd "$WDIR"

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
export PROJECT_NAME="dm2q"
export REGION="eur"
export CARRIER="openx"
export TARGET_BUILD_VARIANT="user"
		
		
#2. kalama (sm8550) common config
CHIPSET_NAME="kalama"

export ANDROID_BUILD_TOP=${WDIR}
export TARGET_PRODUCT=gki
export TARGET_BOARD_PLATFORM=gki

export ANDROID_PRODUCT_OUT=${ANDROID_BUILD_TOP}/out/target/product/dm2q
export OUT_DIR=${ANDROID_BUILD_TOP}/out/msm-kalama-kalama-gki

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
	KMI_SYMBOL_LIST_STRICT_MODE=0
	KMI_ENFORCED=0
	HERMETIC_TOOLCHAIN=0
)

#3. build kernel
build_kernel(){
    cd ${WDIR}/kernel_platform && \
        env ${BUILD_OPTIONS[@]} ${GKI_BUILDSCRIPT} ${CHIPSET_NAME} ${TARGET_PRODUCT} && \
        cd ${WDIR}
}

build_kernel
