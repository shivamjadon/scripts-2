#!/bin/bash

: <<'notice'
 *
 * Script information:
 * Universal and advanced script for Android kernel building.
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
    # WARNING: Although rare, configuring this script incorrectly might result in unexpected behaviour.

    Functions:
    # essential - all required.
    # remote - required if sources not present locally.
    # clang - required if toolchain is clang.
    # optional - not required but might be preferred.
    # predefined - most of the times modifications are not required.
    # script - control how the script behaves and what it does.
    # misc - have a look, but do not touch unless you want to break or fix something.

    Variables:
    # CURRENT_DATE_IN_NAME - if enabled, appends the current date to the kernel zip.
    # KERNEL_LINUX_VERSION_IN_NAME - if enabled, the script appends kernel makefile version variables to the kernel zip.
    # KERNEL_VERSION - your own kernel version.
    # KERNEL_ANDROID_BASE_VERSION_IN_NAME - your kernel Android name/version target.
    # CUSTOM_ZIP_NAME - what you write here will be used as filename for the kernel zip (this discards all zip attributes set).
    # KERNEL_BUILD_USER - your nickname.
    # KERNEL_BUILD_HOST - your Linux distribution's abbreviation.
    # STATS - script-only stats (zip file location, compilation time, etc.).
    # ZIP_BUILDER - makes flashable zip for the kernel.
    # WLAN_KO_PACKER - automatically detects wlan.ko in your kernel dir and copies it to root of AK dir.
    # ASK_FOR_CLEAN_BUILD - if enabled, the script asks you "yes" or "no" for kernel cleaning.
    # RECURSIVE_KERNEL_CLONE - if enabled, the kernel clone is recursive (clones git (sub)modules).
    # STANDALONE_COMPILATION - compilation without output to external dir. Not for usage with Clang.
    # ALWAYS_DELETE_AND_CLONE_AK - on script start AK dir gets deleted everytime.
    # ALWAYS_DELETE_AND_CLONE_KERNEL - on script start the kernel dir gets deleted everytime.
    # REPORT_COMP_TIME_IN_MIN_AND_SEC - if enabled, compilation time is reported in min and sec. If disabled, only in sec.

    Additional help or info:
    # @mscalindt on Telegram and Twitter.
}

function variables() {

    function essential() {
        AK_DIR=
        TOOLCHAIN_DIR=
        KERNEL_DIR=
        KERNEL_OUTPUT_DIR=
        KERNEL_DEFCONFIG=
        KERNEL_NAME=
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

        function ak() {
            AK_NAME=
        }

        function ak_zip_attributes() {
            CURRENT_DATE_IN_NAME=1
            KERNEL_LINUX_VERSION_IN_NAME=0
            KERNEL_VERSION=
            KERNEL_ANDROID_BASE_VERSION_IN_NAME=

            CUSTOM_ZIP_NAME=
        }

        function toolchain() {
            TOOLCHAIN_NAME=
            CLANG_NAME=
        }

        function kernel() {
            KERNEL_BUILD_USER=
            KERNEL_BUILD_HOST=
        }

    ak
    ak_zip_attributes
    toolchain
    kernel
    }

    function script() {
        STATS=1
        USE_CCACHE=1
        ZIP_BUILDER=1
        WLAN_KO_PACKER=0
        ASK_FOR_CLEAN_BUILD=1
        RECURSIVE_KERNEL_CLONE=1
        STANDALONE_COMPILATION=0
        ALWAYS_DELETE_AND_CLONE_AK=0
        ALWAYS_DELETE_AND_CLONE_KERNEL=0
        REPORT_COMP_TIME_IN_MIN_AND_SEC=0
    }

    function predefined() {
        KERNEL_ARCH=arm64
        CLANG_BIN=clang
        CLANG_DIR_PREFIX=aarch64-linux-gnu-
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
        ccache_loc=$(command -v ccache)
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

function automatic_configuration() {
    if [ "$KERNEL_ARCH" = "arm64" ]; then
        kernel_subarch=arm64
    else
        kernel_subarch=arm
    fi

    cd "${tc_dir}"/lib/gcc
    cd -- *
    tc_prefix=$(basename "$PWD")-
}

function configuration_checker() {
    if [ -z "$AK_DIR" ] || [ -z "$TOOLCHAIN_DIR" ] || [ -z "$KERNEL_DIR" ] || [ -z "$KERNEL_OUTPUT_DIR" ] || [ -z "$KERNEL_DEFCONFIG" ] || [ -z "$KERNEL_NAME" ]; then
        printf "\n%bYou did not define all required variables.\nAborting further operations...%b\n\n" "$red" "$darkwhite"
        kill $$
        exit 1
    fi

    if [ ! -d "$ak_dir" ] && [ -z "$AK_REPO" ] && [ -z "$AK_BRANCH" ]; then
        printf "\n%bAnyKernel is missing but you did not define its repo and branch variables.\nAborting further operations...%b\n\n" "$red" "$darkwhite"
        kill $$
        exit 1
    fi

    if [ ! -d "$tc_dir" ] && [ -z "$TOOLCHAIN_REPO" ] && [ -z "$TOOLCHAIN_BRANCH" ]; then
        printf "\n%bToolchain is missing but you did not define its repo and branch variables.\nAborting further operations...%b\n\n" "$red" "$darkwhite"
        kill $$
        exit 1
    fi

    if [ -n "$CLANG_DIR" ]; then
        if [ ! -d "$cg_dir" ] && [ -z "$CLANG_REPO" ] && [ -z "$CLANG_BRANCH" ]; then
            printf "\n%bClang is missing but you did not define its repo and branch variables.\nAborting further operations...%b\n\n" "$red" "$darkwhite"
            kill $$
            exit 1
        fi
    fi

    if [ ! -d "$kl_dir" ] && [ -z "$KERNEL_REPO" ] && [ -z "$KERNEL_BRANCH" ]; then
        printf "\n%bKernel is missing but you did not define its repo and branch variables.\nAborting further operations...%b\n\n" "$red" "$darkwhite"
        kill $$
        exit 1
    fi
}

function cloning() {
    if [ "$ALWAYS_DELETE_AND_CLONE_AK" = 1 ]; then
        if [ -d "$ak_dir" ]; then
            rm -rf "${ak_dir}"
        fi
    fi
    if [ ! -d "$ak_dir" ]; then
        if [ -n "$AK_NAME" ]; then
            printf "\n>>> %bCloning %b%s...%b\n" "$white" "$cyan" "$AK_NAME" "$darkwhite"
        else
            printf "\n>>> %bCloning AnyKernel...%b\n" "$white" "$darkwhite"
        fi
        git clone --branch ${AK_BRANCH} --depth ${ak_clone_depth} ${AK_REPO} "${ak_dir}"
    fi

    if [ ! -d "$tc_dir" ] && [ ! -d "$cg_dir" ]; then
        if [ -n "$TOOLCHAIN_NAME" ] && [ -n "$CLANG_NAME" ]; then
            printf "\n>>> %bCloning %b%s %b+ %b%s...%b\n" "$white" "$cyan" "$TOOLCHAIN_NAME" "$white" "$cyan" "$CLANG_NAME" "$darkwhite"
        elif [ -n "$TOOLCHAIN_NAME" ] && [ -z "$CLANG_NAME" ]; then
            printf "\n>>> %bCloning %b%s %b+ Clang...%b\n" "$white" "$cyan" "$TOOLCHAIN_NAME" "$white" "$darkwhite"
        elif [ -z "$TOOLCHAIN_NAME" ] && [ -n "$CLANG_NAME" ]; then
            printf "\n>>> %bCloning toolchain + %b%s...%b\n" "$white" "$cyan" "$CLANG_NAME" "$darkwhite"
        elif [ -z "$TOOLCHAIN_NAME" ] && [ -z "$CLANG_NAME" ]; then
            printf "\n>>> %bCloning the toolchains...%b\n" "$white" "$darkwhite"
        fi
        git clone --branch ${TOOLCHAIN_BRANCH} --depth ${tc_clone_depth} ${TOOLCHAIN_REPO} "${tc_dir}"
        git clone --branch ${CLANG_BRANCH} --depth ${tc_clone_depth} ${CLANG_REPO} "${cg_dir}"
    elif [ ! -d "$tc_dir" ]; then
        if [ -n "$TOOLCHAIN_NAME" ]; then
            printf "\n>>> %bCloning %b%s...%b\n" "$white" "$cyan" "$TOOLCHAIN_NAME" "$darkwhite"
        else
            printf "\n>>> %bCloning the toolchain...%b\n" "$white" "$darkwhite"
        fi
        git clone --branch ${TOOLCHAIN_BRANCH} --depth ${tc_clone_depth} ${TOOLCHAIN_REPO} "${tc_dir}"
    elif [ ! -d "$cg_dir" ]; then
        if [ -n "$CLANG_NAME" ]; then
            printf "\n>>> %bCloning %b%s...%b\n" "$white" "$cyan" "$CLANG_NAME" "$darkwhite"
        else
            printf "\n>>> %bCloning Clang...%b\n" "$white" "$darkwhite"
        fi
        git clone --branch ${CLANG_BRANCH} --depth ${tc_clone_depth} ${CLANG_REPO} "${cg_dir}"
    fi

    if [ "$ALWAYS_DELETE_AND_CLONE_KERNEL" = 1 ]; then
        if [ -d "$kl_dir" ]; then
            rm -rf "${kl_dir}"
            rm -rf "${out_dir}"
        fi
    fi
    if [ ! -d "$kl_dir" ]; then
        printf "\n>>> %bCloning %b%s...%b\n" "$white" "$cyan" "$KERNEL_NAME" "$darkwhite"
        if [ "$RECURSIVE_KERNEL_CLONE" = 1 ]; then
            git clone --recursive --branch ${KERNEL_BRANCH} --depth ${kl_clone_depth} ${KERNEL_REPO} "${kl_dir}"
        else
            git clone --branch ${KERNEL_BRANCH} --depth ${kl_clone_depth} ${KERNEL_REPO} "${kl_dir}"
        fi
    fi
}

function choices() {
    if [ "$ASK_FOR_CLEAN_BUILD" = 1 ]; then
        if [ -d "$out_dir" ]; then
            printf "\n%bClean from previous build?%b\n" "$white" "$darkwhite"
            select yn1 in "Yes" "No"; do
                case $yn1 in
                    Yes )
                        rm -rf "${out_dir}"
                        break;;
                    No ) break;;
                esac
            done
        elif [ -f "$sde_file" ] || [ -f "$sde_file_2" ]; then
            printf "\n%bClean from previous build?%b\n" "$white" "$darkwhite"
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

    if [ -n "$CLANG_DIR" ]; then
        clg=1
        if [ -n "$CLANG_NAME" ]; then
            printf "\n%b%s detected, starting compilation.%b\n" "$white" "$CLANG_NAME" "$darkwhite"
        else
            printf "\n%bClang detected, starting compilation.%b\n" "$white" "$darkwhite"
        fi
    elif [ "$STANDALONE_COMPILATION" = 0 ]; then
        out=1
        printf "\n%bStarting output folder compilation.%b\n" "$white" "$darkwhite"
    else
        sde=1
        printf "\n%bStarting standalone compilation.%b\n" "$white" "$darkwhite"
    fi
    echo
}

function compilation() {
    start1=$(date +'%s')
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
        export SUBARCH=${kernel_subarch}

        make O="${out_dir}" \
            ARCH=${KERNEL_ARCH} \
            ${KERNEL_DEFCONFIG}

        if [ "$USE_CCACHE" = 1 ]; then
            cs="${ccache_loc} ${cg_dir}/bin:${tc_dir}/bin:${cs}" \
            make O="${out_dir}" \
                ARCH=${KERNEL_ARCH} \
                CC="${cg_dir}"/bin/${CLANG_BIN} \
                CLANG_TRIPLE=${CLANG_DIR_PREFIX} \
                CROSS_COMPILE="${tc_prefix}" \
                -j"$(nproc --all)"
        else
            cs="${cg_dir}/bin:${tc_dir}/bin:${cs}" \
            make O="${out_dir}" \
                ARCH=${KERNEL_ARCH} \
                CC="${cg_dir}"/bin/${CLANG_BIN} \
                CLANG_TRIPLE=${CLANG_DIR_PREFIX} \
                CROSS_COMPILE="${tc_prefix}" \
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
        export SUBARCH=${kernel_subarch}
        if [ "$USE_CCACHE" = 1 ]; then
            export CROSS_COMPILE="${ccache_loc} ${tc_dir}/bin/${tc_prefix}"
        else
            export CROSS_COMPILE="${tc_dir}/bin/${tc_prefix}"
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
        export SUBARCH=${kernel_subarch}
        if [ "$USE_CCACHE" = 1 ]; then
            CROSS_COMPILE="${ccache_loc} ${tc_dir}/bin/${tc_prefix}"
        else
            CROSS_COMPILE="${tc_dir}/bin/${tc_prefix}"
        fi

        make ${KERNEL_DEFCONFIG}

        CROSS_COMPILE=${CROSS_COMPILE} make -j"$(nproc --all)"
    fi
    end1=$(date +'%s')
    comptime=$((end1-start1))
}

function compilation_report() {
    if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
        if [ -f "$out_kl_img" ]; then
            if [ "$STATS" = 1 ] && [ "$ZIP_BUILDER" = 1 ]; then
                printf "\n%bThe kernel is compiled successfully!%b\n" "$green" "$darkwhite"
            elif [ "$STATS" = 0 ] && [ "$ZIP_BUILDER" = 0 ]; then
                printf "\n%bThe kernel is compiled successfully!%b\n\n" "$green" "$darkwhite"
            else
                printf "\n%bThe kernel is compiled successfully!%b\n" "$green" "$darkwhite"
            fi
        else
            printf "\n%bThe kernel was not compiled correctly, check the log for errors.\nAborting further operations...%b\n\n" "$red" "$darkwhite"
            kill $$
            exit 1
        fi
    elif [ "$sde" = 1 ]; then
        if [ -f "$sde_kl_img" ]; then
            if [ "$STATS" = 1 ] && [ "$ZIP_BUILDER" = 1 ]; then
                printf "\n%bThe kernel is compiled successfully!%b\n" "$green" "$darkwhite"
            elif [ "$STATS" = 0 ] && [ "$ZIP_BUILDER" = 0 ]; then
                printf "\n%bThe kernel is compiled successfully!%b\n\n" "$green" "$darkwhite"
            else
                printf "\n%bThe kernel is compiled successfully!%b\n" "$green" "$darkwhite"
            fi
        else
            printf "\n%bThe kernel was not compiled correctly, check the log for errors.\nAborting further operations...%b\n\n" "$red" "$darkwhite"
            kill $$
            exit 1
        fi
    fi
}

function zip_builder() {
    kernel_linux_version=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')

    if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
        cp "${out_kl_img}" "${ak_kl_img}"
    elif [ "$sde" = 1 ]; then
        cp "${sde_kl_img}" "${ak_kl_img}"
    fi
    if [ "$WLAN_KO_PACKER" = 1 ]; then 
        printf "%bImage.gz-dtb copied.%b\n" "$green" "$darkwhite"
    else
        printf "%bImage.gz-dtb copied.%b\n\n" "$green" "$darkwhite"
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
            printf "%bwlan.ko copied.%b\n\n" "$green" "$darkwhite"
        else
            printf "%bwlan.ko could not be detected. %bContinuing without it...%b\n\n" "$red" "$white" "$darkwhite"
        fi
    fi

    if [ -n "$CUSTOM_ZIP_NAME" ]; then
        file_name="${CUSTOM_ZIP_NAME}.zip"
    elif [ -n "$KERNEL_VERSION" ] && [ -n "$KERNEL_ANDROID_BASE_VERSION_IN_NAME" ]; then
        if [ "$CURRENT_DATE_IN_NAME" = 1 ] && [ "$KERNEL_LINUX_VERSION_IN_NAME" = 1 ]; then
            file_name="${KERNEL_NAME}-${KERNEL_VERSION}-${kernel_linux_version}-${KERNEL_ANDROID_BASE_VERSION_IN_NAME}-${current_date}.zip"
        elif [ "$CURRENT_DATE_IN_NAME" = 1 ]; then
            file_name="${KERNEL_NAME}-${KERNEL_VERSION}-${KERNEL_ANDROID_BASE_VERSION_IN_NAME}-${current_date}.zip"
        else
            file_name="${KERNEL_NAME}-${KERNEL_VERSION}-${kernel_linux_version}-${KERNEL_ANDROID_BASE_VERSION_IN_NAME}.zip"
        fi
    elif [ -n "$KERNEL_VERSION" ]; then
        if [ "$CURRENT_DATE_IN_NAME" = 1 ] && [ "$KERNEL_LINUX_VERSION_IN_NAME" = 1 ]; then
            file_name="${KERNEL_NAME}-${KERNEL_VERSION}-${kernel_linux_version}-${current_date}.zip"
        elif [ "$CURRENT_DATE_IN_NAME" = 1 ]; then
            file_name="${KERNEL_NAME}-${KERNEL_VERSION}-${current_date}.zip"
        else
            file_name="${KERNEL_NAME}-${KERNEL_VERSION}-${kernel_linux_version}.zip"
        fi
    else
        if [ "$CURRENT_DATE_IN_NAME" = 1 ] && [ "$KERNEL_LINUX_VERSION_IN_NAME" = 1 ]; then
            file_name="${KERNEL_NAME}-${kernel_linux_version}-${KERNEL_ANDROID_BASE_VERSION_IN_NAME}-${current_date}.zip"
        elif [ "$CURRENT_DATE_IN_NAME" = 1 ]; then
            file_name="${KERNEL_NAME}-${KERNEL_ANDROID_BASE_VERSION_IN_NAME}-${current_date}.zip"
        else
            file_name="${KERNEL_NAME}-${kernel_linux_version}-${KERNEL_ANDROID_BASE_VERSION_IN_NAME}.zip"
        fi
    fi

    if [ "$KERNEL_LINUX_VERSION_IN_NAME" = 1 ]; then
        printf "%b> Packing %b%s %s %bkernel...%b\n\n" "$white" "$cyan" "$KERNEL_NAME" "$kernel_linux_version" "$white" "$darkwhite"
    else
        printf "%b> Packing %b%s %bkernel...%b\n\n" "$white" "$cyan" "$KERNEL_NAME" "$white" "$darkwhite"
    fi

    pushd "${ak_dir}"
        zip -FSr9 "${file_name}" ./* -x .git README.md
    popd
    
    if [ "$STATS" = 0 ]; then
        echo
    fi
}

function stats() {

    function convert_bytes() {
        b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,P,E,Z,Y}B)
        while ((b > 1000)); do
            d="$(printf ".%02d" $((b % 1000 * 100 / 1000)))"
            b=$((b / 1000))
            (( s++ ))
        done
        echo "$b$d ${S[$s]}"
    }

    if [ "$ZIP_BUILDER" = 1 ]; then
        byteszip=$(stat -c %s "${ak_dir}"/"${file_name}")
    elif [ "$ZIP_BUILDER" = 0 ] && [ "$out" = 1 ]; then
        bytesoutimg=$(stat -c %s "${out_kl_img}")
    else
        bytessdeimg=$(stat -c %s "${sde_kl_img}")
    fi

    if [ "$ZIP_BUILDER" = 1 ]; then
        sizezip=$(convert_bytes "${byteszip}")
    elif [ "$ZIP_BUILDER" = 0 ] && [ "$out" = 1 ]; then
        sizeoutimg=$(convert_bytes "${bytesoutimg}")
    else
        sizesdeimg=$(convert_bytes "${bytessdeimg}")
    fi

    echo

    if [ -n "$KERNEL_BUILD_USER" ]; then
        printf " %b> User: %s\n" "$white" "$KERNEL_BUILD_USER"
    else
        printf " %b> User: %s\n" "$white" "$idkme"
    fi

    if [ -n "$KERNEL_BUILD_HOST" ]; then
        printf " %b> Host: %s\n" "$white" "$KERNEL_BUILD_HOST"
    else
        printf " %b> Host: %s\n" "$white" "$idkmy"
    fi

    if [ "$ZIP_BUILDER" = 1 ]; then
        printf " %b> File location: %s/%s\n" "$white" "$ak_dir" "$file_name"
    elif [ "$ZIP_BUILDER" = 0 ] && [ "$out" = 1 ]; then
        printf " %b> Kernel image location: %s\n" "$white" "$out_kl_img"
    else
        printf " %b> Kernel image location: %s\n" "$white" "$sde_kl_img"
    fi

    if [ "$ZIP_BUILDER" = 1 ]; then
        printf " %b> File size: %s\n" "$white" "$sizezip"
    elif [ "$ZIP_BUILDER" = 0 ] && [ "$out" = 1 ]; then
        printf " %b> Kernel image size: %s\n" "$white" "$sizeoutimg"
    else
        printf " %b> Kernel image size: %s\n" "$white" "$sizesdeimg"
    fi

    if [ "$REPORT_COMP_TIME_IN_MIN_AND_SEC" = 0 ]; then
        printf " %b> Compilation took: %d seconds%b\n" "$white" "$comptime" "$darkwhite"
    else
        printf " %b> Compilation took: $((comptime / 60)) minute(s) and $((comptime % 60)) second(s)%b\n" "$white" "$darkwhite"
    fi

    if [ "$clg" = 1 ]; then
        if [ "$USE_CCACHE" = 1 ]; then
            printf " %b> Compilation details: out-%s-ccache\n\n" "$white" "$CLANG_BIN"
        else
            printf " %b> Compilation details: out-%s\n\n" "$white" "$CLANG_BIN"
        fi
    elif [ "$out" = 1 ]; then
        if [ "$USE_CCACHE" = 1 ]; then
            printf " %b> Compilation details: out-gcc-ccache\n\n" "$white"
        else
            printf " %b> Compilation details: out-gcc\n\n" "$white"
        fi
    elif [ "$sde" = 1 ]; then
        if [ "$USE_CCACHE" = 1 ]; then
            printf " %b> Compilation details: standalone-gcc-ccache\n\n" "$white"
        else
            printf " %b> Compilation details: standalone-gcc\n\n" "$white"
        fi
    fi
}

variables
automatic_configuration
configuration_checker
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
