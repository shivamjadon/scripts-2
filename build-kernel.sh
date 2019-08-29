#!/bin/bash

<<notice
 *
 * Script information:
 * Universal script for Android kernel building.
 * Indentation space is 4 and is space characters.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

function info() {
    # NOTE: Read all the text in the current function, or save yourself 1 hour by trial and error.
    # NOTE: You only have to configure the function "variables" and its nested functions.
    # NOTE: 1 means enabled. Anything else means disabled.
    # NOTE: Do NOT use space in any variable, instead use dot (.) or dash (-), and NEVER end variables with slash (/).
    # NOTE: You can leave REPO/BRANCH variables empty. If defined, they activate only if any source is missing!
    # WARNING: Configuring this script incorrectly might result in unexpected behaviour.

    Functions:
    # essential - all required.
    # remote - required if sources not present locally.
    # clang - required if toolchain is clang.
    # optional - not required but might be preferred.
    # predefined - most of the times modifications are not required.
    # script - control how the script behaves and what it does.
    # misc - have a look, but do not touch unless you want to break or fix something.

    Variables:
    # KERNEL_BUILD_USER - your nickname.
    # KERNEL_BUILD_HOST - your Linux distribution's abbreviation.
    # CUSTOM_ZIP_NAME - what you write here will be used as the kernel's zip name.
    # STATS - script-only stats (zip file location, compilation time, etc.).
    # ZIP_BUILDER - makes flashable zip for the kernel.
    # WLAN_KO_PACKER - automatically detects wlan.ko in your kernel dir and copies it to root of AK dir.
    # ASK_FOR_CLEAN_BUILD - if enabled, the script asks you "yes" or "no" for kernel cleaning.
    # ASK_FOR_AK_CLEANING - if enabled, the script asks you "yes" or "no" for AK dir cleaning.
    # RECURSIVE_KERNEL_CLONE - enable if your kernel has git (sub)modules.
    # STANDALONE_COMPILATION - compilation without output to external dir. Not for usage with Clang.
    # ALWAYS_DELETE_AND_CLONE_AK - on script start AK dir gets deleted everytime.
    # ALWAYS_DELETE_AND_CLONE_KERNEL - on script start the kernel dir gets deleted everytime.

    Additional help or info:
    # @mscalindt on Telegram and Twitter.
}

function variables() {

    function essential() {
        AK_DIR=
        TOOLCHAIN_DIR=
        TOOLCHAIN_DIR_PREFIX=
        KERNEL_DIR=
        KERNEL_OUTPUT_DIR=
        KERNEL_DEFCONFIG=
    }

    function remote() {
        AK_REPO=
        AK_BRANCH=
        TOOLCHAIN_REPO=
        TOOLCHAIN_BRANCH=
        KERNEL_REPO=
        KERNEL_BRANCH=
    }

    function clang() {
        CLANG_REPO=
        CLANG_BRANCH=
        CLANG_DIR=
    }

    function optional() {
        AK_NAME=
        TOOLCHAIN_NAME=
        CLANG_NAME=
        KERNEL_NAME=
        KERNEL_BUILD_USER=
        KERNEL_BUILD_HOST=
        KERNEL_VERSION_IN_ZIP_NAME=1
        KERNEL_ANDROID_BASE_VERSION=
        CUSTOM_ZIP_NAME=
    }

    function script() {
        STATS=1
        USE_CCACHE=1
        ZIP_BUILDER=1
        WLAN_KO_PACKER=0
        ASK_FOR_CLEAN_BUILD=1
        ASK_FOR_AK_CLEANING=1
        RECURSIVE_KERNEL_CLONE=0
        STANDALONE_COMPILATION=0
        ALWAYS_DELETE_AND_CLONE_AK=0
        ALWAYS_DELETE_AND_CLONE_KERNEL=0
    }

    function predefined() {
        KERNEL_ARCH=arm64
        KERNEL_SUBARCH=arm64
        CLANG_BIN=clang
        CLANG_DIR_PREFIX=aarch64-linux-gnu-
        CCACHE_LOCATION=/usr/bin/ccache
    }

    function misc() {
        red='\033[1;31m'
        green='\033[1;32m'
        white='\033[1;37m'
        cyan='\033[1;36m'
        darkwhite='\033[0;37m'
        ak_clone_depth=1
        tc_clone_depth=1
        kl_clone_depth=10
        current_date=$(date +'%Y%m%d')
        idkme=$(whoami)
        idkmy=$(uname -n)
        clg=bad
        out=and
        sde=boujee
        ak_dir="$HOME"/${AK_DIR}
        tc_dir="$HOME"/${TOOLCHAIN_DIR}
        cg_dir="$HOME"/${CLANG_DIR}
        kl_dir="$HOME"/${KERNEL_DIR}
        out_dir="$HOME"/${KERNEL_OUTPUT_DIR}
        sde_file="$HOME"/${KERNEL_DIR}/arch/arm64/crypto/built-in.o
        sde_file_2="$HOME"/${KERNEL_DIR}/arch/arm64/kernel/built-in.o
        ak_kl_img="$HOME"/${AK_DIR}/zImage
        wl_file="$HOME"/${AK_DIR}/wlan.ko
        out_kl_img="$HOME"/${KERNEL_OUTPUT_DIR}/arch/arm64/boot/Image.gz-dtb
        sde_kl_img="$HOME"/${KERNEL_DIR}/arch/arm64/boot/Image.gz-dtb
    }

essential
remote
clang
optional
script
predefined
misc
}

function cloning() {
    if [ -n "$AK_REPO" ] && [ -n "$AK_BRANCH" ]; then
        if [ "$ALWAYS_DELETE_AND_CLONE_AK" = 1 ]; then
            if [ -d "$ak_dir" ]; then
                rm -rf "${ak_dir}"
            fi
        fi
        if [ ! -d "$ak_dir" ]; then
            if [ -n "$AK_NAME" ]; then
                printf "\n>>> ${white}Cloning ${cyan}${AK_NAME}${darkwhite}...\n"
            else
                printf "\n>>> ${white}Cloning AnyKernel${darkwhite}...\n"
            fi
            git clone --branch ${AK_BRANCH} --depth ${ak_clone_depth} ${AK_REPO} "${ak_dir}"
        fi
    fi

    if [ -n "$TOOLCHAIN_REPO" ] && [ -n "$TOOLCHAIN_BRANCH" ]; then
        if [ -n "$CLANG_REPO" ] && [ -n "$CLANG_BRANCH" ]; then
            if [ ! -d "$tc_dir" ] && [ ! -d "$cg_dir" ]; then
                if [ -n "$TOOLCHAIN_NAME" ] && [ -n "$CLANG_NAME" ]; then
                    printf "\n>>> ${white}Cloning ${cyan}${TOOLCHAIN_NAME} ${white}+ ${cyan}${CLANG_NAME}${darkwhite}...\n"
                elif [ -n "$TOOLCHAIN_NAME" ] && [ -z "$CLANG_NAME" ]; then
                    printf "\n>>> ${white}Cloning ${cyan}${TOOLCHAIN_NAME} ${white}+ Clang${darkwhite}...\n"
                elif [ -z "$TOOLCHAIN_NAME" ] && [ -n "$CLANG_NAME" ]; then
                    printf "\n>>> ${white}Cloning toolchain + ${cyan}${CLANG_NAME}${darkwhite}...\n"
                elif [ -z "$TOOLCHAIN_NAME" ] && [ -z "$CLANG_NAME" ]; then
                    printf "\n>>> ${white}Cloning the toolchains${darkwhite}...\n"
                fi
                git clone --branch ${TOOLCHAIN_BRANCH} --depth ${tc_clone_depth} ${TOOLCHAIN_REPO} "${tc_dir}"
                git clone --branch ${CLANG_BRANCH} --depth ${tc_clone_depth} ${CLANG_REPO} "${cg_dir}"
            elif [ ! -d "$cg_dir" ]; then
                if [ -n "$CLANG_NAME" ]; then
                    printf "\n>>> ${white}Cloning ${cyan}${CLANG_NAME}${darkwhite}...\n"
                else
                    printf "\n>>> ${white}Cloning Clang${darkwhite}...\n"
                fi
                git clone --branch ${CLANG_BRANCH} --depth ${tc_clone_depth} ${CLANG_REPO} "${cg_dir}"
            fi
        elif [ ! -d "$tc_dir" ]; then
            if [ -n "$TOOLCHAIN_NAME" ]; then
                printf "\n>>> ${white}Cloning ${cyan}${TOOLCHAIN_NAME}${darkwhite}...\n"
            else
                printf "\n>>> ${white}Cloning the toolchain${darkwhite}...\n"
            fi
            git clone --branch ${TOOLCHAIN_BRANCH} --depth ${tc_clone_depth} ${TOOLCHAIN_REPO} "${tc_dir}"
        fi
    fi

    if [ -n "$KERNEL_REPO" ] && [ -n "$KERNEL_BRANCH" ]; then
        if [ "$ALWAYS_DELETE_AND_CLONE_KERNEL" = 1 ]; then
            if [ -d "$kl_dir" ]; then
                rm -rf "${kl_dir}"
                rm -rf "${out_dir}"
            fi
        fi
        if [ ! -d "$kl_dir" ]; then
            if [ -n "$KERNEL_NAME" ]; then
                printf "\n>>> ${white}Cloning ${cyan}${KERNEL_NAME}${darkwhite}...\n"
            else
                printf "\n>>> ${white}Cloning the kernel${darkwhite}...\n"
            fi
            if [ "$RECURSIVE_KERNEL_CLONE" = 0 ]; then
                git clone --branch ${KERNEL_BRANCH} --depth ${kl_clone_depth} ${KERNEL_REPO} "${kl_dir}"
            else
                git clone --recursive --branch ${KERNEL_BRANCH} --depth ${kl_clone_depth} ${KERNEL_REPO} "${out_dir}"
            fi
        fi
    fi
}

function choices() {
    if [ "$ASK_FOR_CLEAN_BUILD" = 1 ]; then
        if [ -d "$out_dir" ]; then
            printf "\n${white}Clean from previous output build?${darkwhite}\n"
            select yn1 in "Yes" "No"; do
                case $yn1 in
                    Yes )
                        rm -rf "${out_dir}"
                        break;;
                    No ) break;;
                esac
            done
        elif [ -f "$sde_file" ] || [ -f "$sde_file_2" ]; then
            printf "\n${white}Clean from previous standalone build?${darkwhite}\n"
            select yn1 in "Yes" "No"; do
                case $yn1 in
                    Yes )
                        cd "${kl_dir}"
                        make clean
                        make mrproper
                        break;;
                    No ) break;;
                esac
            done
        fi
    fi

    if [ "$ASK_FOR_AK_CLEANING" = 1 ]; then
        if [ -f "$ak_kl_img" ]; then
            printf "\n${white}Clean ${AK_DIR} folder?${darkwhite}\n"
            select yn2 in "Yes" "No"; do
                case $yn2 in
                    Yes )
                        rm -fv "${ak_kl_img}"
                        if [ -n "$CUSTOM_ZIP_NAME" ]; then
                            find "${ak_dir}" -name "$CUSTOM_ZIP_NAME" -type f -exec rm -fv {} \;
                        elif [ -n "$KERNEL_NAME" ]; then
                        	find "${ak_dir}" -name "*$KERNEL_NAME*" -type f -exec rm -fv {} \;
                        else
                            find "${ak_dir}" -name "*$idkme*" -type f -exec rm -fv {} \;
                        fi
                        if [ "$WLAN_KO_PACKER" = 1 ]; then
                            if [ -f "$wl_file" ]; then
                                rm -fv "${wl_file}"
                            fi
                        fi
                        break;;
                    No ) break;;
                esac
            done
        fi
    fi

    if [ -n "$CLANG_DIR" ]; then
        clg=1
        if [ -n "$CLANG_NAME" ]; then
            printf "\n${white}${CLANG_NAME} detected, starting compilation.${darkwhite}\n"
        else
            printf "\n${white}Clang detected, starting compilation.${darkwhite}\n"
        fi
    elif [ "$STANDALONE_COMPILATION" = 0 ]; then
        out=1
        printf "\n${white}Starting output folder compilation.${darkwhite}\n"
    else
        sde=1
        printf "\n${white}Starting standalone compilation.${darkwhite}\n"
    fi
    echo
}

function compilation() {
    start1=$SECONDS
    if [ "$clg" = 1 ]; then
        cd "${kl_dir}"

        if [ -n "$KERNEL_BUILD_USER" ]; then
            export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
        else
            export KBUILD_BUILD_USER=${idkme}
        fi
        if [ -n "$KERNEL_BUILD_HOST" ]; then
            export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
        else
            export KBUILD_BUILD_HOST=${idkmy}
        fi
        export ARCH=${KERNEL_ARCH}
        export SUBARCH=${KERNEL_SUBARCH}

        make O="${out_dir}" \
            ARCH=${KERNEL_ARCH} \
            ${KERNEL_DEFCONFIG}

        if [ "$USE_CCACHE" = 1 ]; then
            cs="${CCACHE_LOCATION} ${cg_dir}/bin:${tc_dir}/bin:${cs}" \
            make O="${out_dir}" \
            ARCH=${KERNEL_ARCH} \
            CC="${cg_dir}"/bin/${CLANG_BIN} \
            CLANG_TRIPLE=${CLANG_DIR_PREFIX} \
            CROSS_COMPILE=${TOOLCHAIN_DIR_PREFIX} \
            -j"$(nproc --all)"
        else
            cs="${cg_dir}/bin:${tc_dir}/bin:${cs}" \
            make O="${out_dir}" \
            ARCH=${KERNEL_ARCH} \
            CC="${cg_dir}"/bin/${CLANG_BIN} \
            CLANG_TRIPLE=${CLANG_DIR_PREFIX} \
            CROSS_COMPILE=${TOOLCHAIN_DIR_PREFIX} \
            -j"$(nproc --all)"
        fi
    elif [ "$out" = 1 ]; then
        cd "${kl_dir}"

        if [ -n "$KERNEL_BUILD_USER" ]; then
            export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
        else
            export KBUILD_BUILD_USER=${idkme}
        fi
        if [ -n "$KERNEL_BUILD_HOST" ]; then
            export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
        else
            export KBUILD_BUILD_HOST=${idkmy}
        fi
        export ARCH=${KERNEL_ARCH}
        export SUBARCH=${KERNEL_SUBARCH}
        if [ "$USE_CCACHE" = 1 ]; then
            export CROSS_COMPILE="${CCACHE_LOCATION} ${tc_dir}/bin/${TOOLCHAIN_DIR_PREFIX}"
        else
            export CROSS_COMPILE="${tc_dir}/bin/${TOOLCHAIN_DIR_PREFIX}"
        fi

        make O="${out_dir}" \
            ARCH=${KERNEL_ARCH} \
            ${KERNEL_DEFCONFIG}

        make O="${out_dir}" \
            ARCH=${KERNEL_ARCH} \
            -j"$(nproc --all)"
    elif [ "$sde" = 1 ]; then
        cd "${kl_dir}"

        export ARCH=${KERNEL_ARCH}
        export SUBARCH=${KERNEL_SUBARCH}
        if [ "$USE_CCACHE" = 1 ]; then
            CROSS_COMPILE="${CCACHE_LOCATION} ${tc_dir}/bin/${TOOLCHAIN_DIR_PREFIX}"
        else
            CROSS_COMPILE="${tc_dir}/bin/${TOOLCHAIN_DIR_PREFIX}"
        fi

        make ${KERNEL_DEFCONFIG}

        CROSS_COMPILE=${CROSS_COMPILE} make -j"$(nproc --all)"
    fi
    end1=$SECONDS
}

function compilation_report() {
    if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
        if [ -f "$out_kl_img" ]; then
            printf "\n${green}The kernel is compiled successfully!${darkwhite}\n"
        else
            printf "\n${red}The kernel was not compiled correctly, check the log for errors.\nAborting further operations...${darkwhite}\n\n"
            kill $$
            exit 1
        fi
    elif [ "$sde" = 1 ]; then
        if [ -f "$sde_kl_img" ]; then
            printf "\n${green}The kernel is compiled successfully!${darkwhite}\n"
        else
            printf "\n${red}The kernel was not compiled correctly, check the log for errors.\nAborting further operations...${darkwhite}\n\n"
            kill $$
            exit 1
        fi
    fi
}

function zip_builder() {
    kernel_version=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')

    if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
        cp "${out_kl_img}" "${ak_kl_img}"
    elif [ "$sde" = 1 ]; then
        cp "${sde_kl_img}" "${ak_kl_img}"
    fi
    if [ "$WLAN_KO_PACKER" = 1 ]; then 
        printf "${green}Image.gz-dtb copied.${darkwhite}\n"
    else
        printf "${green}Image.gz-dtb copied.${darkwhite}\n\n"
    fi

    if [ "$WLAN_KO_PACKER" = 1 ]; then
        if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
            cd "$(find "${out_dir}" -type d -name "HDD")"
            cd ../..
            if [ -f "wlan.ko" ]; then
                wlan_ko_found1=1
            else
                wlan_ko_found1=0
            fi
        elif [ "$sde" = 1 ]; then
            cd "$(find "${kl_dir}" -type d -name "HDD")"
            cd ../..
            if [ -f "wlan.ko" ]; then
                wlan_ko_found1=1
            else
                wlan_ko_found1=0
            fi
        fi

        if [ "$wlan_ko_found1" = 0 ]; then
            if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
                cd "$(find "${out_dir}" -type d -name "hdd")"
                cd ../..
                if [ -f "wlan.ko" ]; then
                    wlan_ko_found2=1
                else
                    wlan_ko_found2=0
                fi
            elif [ "$sde" = 1 ]; then
                cd "$(find "${kl_dir}" -type d -name "hdd")"
                cd ../..
                if [ -f "wlan.ko" ]; then
                    wlan_ko_found2=1
                else
                    wlan_ko_found2=0
                fi
            fi
        fi

        if [ "$wlan_ko_found1" = 1 ] || [ "$wlan_ko_found2" = 1 ]; then
            cp wlan.ko "${ak_dir}"
            printf "${green}wlan.ko copied.${darkwhite}\n\n"
        else
            printf "${red}wlan.ko could not be detected. ${white}Continuing without it...${darkwhite}\n\n"
        fi
    fi

    if [ -n "$CUSTOM_ZIP_NAME" ]; then
        file_name="${CUSTOM_ZIP_NAME}.zip"
    elif [ -n "$KERNEL_NAME" ] && [ -n "$KERNEL_ANDROID_BASE_VERSION" ]; then
        if [ "$KERNEL_VERSION_IN_ZIP_NAME" = 1 ]; then
            file_name="${KERNEL_NAME}-${kernel_version}-${KERNEL_ANDROID_BASE_VERSION}-${current_date}.zip"
        else
            file_name="${KERNEL_NAME}-${KERNEL_ANDROID_BASE_VERSION}-${current_date}.zip"
        fi
    elif [ -n "$KERNEL_NAME" ]; then
        if [ "$KERNEL_VERSION_IN_ZIP_NAME" = 1 ]; then
            file_name="${KERNEL_NAME}-${kernel_version}-${current_date}.zip"
        else
            file_name="${KERNEL_NAME}-${current_date}.zip"
        fi
    else
        file_name="${idkme}.Kernel-${current_date}.zip"
    fi

    if [ "$KERNEL_VERSION_IN_ZIP_NAME" = 1 ]; then
        printf "${white}> Packing ${cyan}${KERNEL_NAME} ${kernel_version} ${white}kernel...${darkwhite}\n\n"
    else
        printf "${white}> Packing ${cyan}${KERNEL_NAME} ${white}kernel...${darkwhite}\n\n"
    fi
    pushd "${ak_dir}"
        zip -r9 "${file_name}" * -x .git README.md
    popd
}

function stats() {
    size=$(ls -lah "${ak_dir}"/"${file_name}" | awk '{print $5}')
    echo

    if [ -n "$KERNEL_BUILD_USER" ]; then
        printf " ${white}> User: ${KERNEL_BUILD_USER}\n"
    else
        printf " ${white}> User: ${idkme}\n"
    fi

    if [ -n "$KERNEL_BUILD_HOST" ]; then
        printf " ${white}> Host: ${KERNEL_BUILD_HOST}\n"
    else
        printf " ${white}> Host: ${idkmy}\n"
    fi

    printf " ${white}> File location: ${ak_dir}/${file_name}\n"
    printf " ${white}> File size: ${size}B\n"
    printf " ${white}> Compilation took: $((end1-start1)) seconds${darkwhite}\n"

    if [ "$clg" = 1 ]; then
        if [ "$USE_CCACHE" = 1 ]; then
            printf " ${white}> Compilation details: out-${CLANG_BIN}-ccache\n\n"
        else
            printf " ${white}> Compilation details: out-${CLANG_BIN}\n\n"
        fi
    elif [ "$out" = 1 ]; then
        if [ "$USE_CCACHE" = 1 ]; then
            printf " ${white}> Compilation details: out-gcc-ccache\n\n"
        else
            printf " ${white}> Compilation details: out-gcc\n\n"
        fi
    elif [ "$sde" = 1 ]; then
        if [ "$USE_CCACHE" = 1 ]; then
            printf " ${white}> Compilation details: standalone-gcc-ccache\n\n"
        else
            printf " ${white}> Compilation details: standalone-gcc\n\n"
        fi
    fi
}

variables
cloning
choices
compilation
compilation_report
if [ "$ZIP_BUILDER" = 1 ]; then
  zip_builder
fi
if [ "$STATS" = 1 ]; then
  stats
fi
