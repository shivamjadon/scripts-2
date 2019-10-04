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

bash_ver=${BASH_VERSION}
bash_ver_cut=$(printf "%s" "$bash_ver" | cut -c -1)
if [ "$bash_ver_cut" = "2" ] || [ "$bash_ver_cut" = "3" ]; then
    printf "\n%bThis script requires bash 4+%b\n\n" "\033[1;31m" "\033[0;37m"
    exit 1
fi

if [ $EUID = 0 ]; then
    printf "\n%bYou should not run this script as root.%b\n\n" "\033[1;31m" "\033[0;37m"
    exit 1
fi

function variables() {

    ESSENTIAL_VARIABLES() {
        TOOLCHAIN_DIR=
        KERNEL_DIR=
        KERNEL_OUTPUT_DIR=
        KERNEL_DEFCONFIG=
        KERNEL_NAME=
        KERNEL_ARCH=
    }

    SCRIPT_VARIABLES() {
        STATS=0
        USE_CCACHE=0
        ZIP_BUILDER=0
        ASK_FOR_CLEAN_BUILD=0
        DELETE_OLD_ZIP_IN_AK=0
        RECURSIVE_KERNEL_CLONE=0
        STANDALONE_COMPILATION=0
    }

    OPTIONAL_VARIABLES() {

        anykernel() {
            essential_variables() {
                AK_DIR=
            }
            remote_variables() {
                AK_REPO=
                AK_BRANCH=
            }
            zip_filename_variables() {
                APPEND_DATE=0
                APPEND_LINUX_VERSION=0
                APPEND_VERSION=
                APPEND_ANDROID_TARGET=
                CUSTOM_ZIP_NAME=
            }
            essential_variables
            remote_variables
            zip_filename_variables
        }

        toolchain() {
            remote_variables() {
                TOOLCHAIN_REPO=
                TOOLCHAIN_BRANCH=
            }
            remote_variables
        }

        clang() {
            essential_variables() {
                CLANG_DIR=
                CLANG_BIN=
                CLANG_PREFIX=
            }
            remote_variables() {
                CLANG_REPO=
                CLANG_BRANCH=
            }
            essential_variables
            remote_variables
        }

        kernel() {
            remote_variables() {
                KERNEL_REPO=
                KERNEL_BRANCH=
            }
            options() {
                KERNEL_BUILD_USER=
                KERNEL_BUILD_HOST=
                KERNEL_LOCALVERSION=
            }
            remote_variables
            options
        }

        anykernel
        toolchain
        clang
        kernel
    }

    ESSENTIAL_VARIABLES
    SCRIPT_VARIABLES
    OPTIONAL_VARIABLES
}

function additional_variables() {
    red='\033[1;31m'
    green='\033[1;32m'
    white='\033[1;37m'
    darkwhite='\033[0;37m'
    ak_clone_depth=1
    tc_clone_depth=1
    kl_clone_depth=10
    current_date=$(date +'%Y%m%d')
    clg=bad
    out=and
    sde=boujee
    ak_dir="$HOME"/${AK_DIR}
    tc_dir="$HOME"/${TOOLCHAIN_DIR}
    cg_dir="$HOME"/${CLANG_DIR}
    kl_dir="$HOME"/${KERNEL_DIR}
    out_dir="$HOME"/${KERNEL_OUTPUT_DIR}
    sde_file="$HOME"/${KERNEL_DIR}/scripts/kconfig/conf.o
    ak_kl_img="$HOME"/${AK_DIR}/zImage
    out_kl_img="$HOME"/${KERNEL_OUTPUT_DIR}/arch/arm64/boot/Image.gz-dtb
    sde_kl_img="$HOME"/${KERNEL_DIR}/arch/arm64/boot/Image.gz-dtb
}

function die_codes() {

    die_10() {
        # Package not found
        exit 10
    }

    die_20() {
        printf "\n%bYou did not define all building essential variables.\nExit code: 20.%b\n\n" "$red" "$darkwhite"
        exit 20
    }

    die_21() {
        # Incorrect definition of an variable
        exit 21
    }

    die_22() {
        # Incompatible variable configuration
        exit 22
    }

    die_30() {
        printf "\n%bUnexpected path issue.\nExit code: 30.%b\n\n" "$red" "$darkwhite"
        exit 30
    }

    die_40() {
        printf "\n%bThe kernel was not compiled correctly, check the log for errors.%b\n\n" "$red" "$darkwhite"
        exit 40
    }
}

function configuration_checker() {

    undefined_variables_check() {
        if [ -z "$TOOLCHAIN_DIR" ] || [ -z "$KERNEL_DIR" ] || \
        [ -z "$KERNEL_OUTPUT_DIR" ] || [ -z "$KERNEL_DEFCONFIG" ] || \
        [ -z "$KERNEL_NAME" ] || [ -z "$KERNEL_ARCH" ]; then
            die_20
        fi
    }

    toggles_check() {
        if [ "$STATS" != 0 ] && [ "$STATS" != 1 ]; then
            printf "\n%bIncorrect STATS variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$USE_CCACHE" != 0 ] && [ "$USE_CCACHE" != 1 ]; then
            printf "\n%bIncorrect USE_CCACHE variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$ZIP_BUILDER" != 0 ] && [ "$ZIP_BUILDER" != 1 ]; then
            printf "\n%bIncorrect ZIP_BUILDER variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$ASK_FOR_CLEAN_BUILD" != 0 ] && [ "$ASK_FOR_CLEAN_BUILD" != 1 ]; then
            printf "\n%bIncorrect ASK_FOR_CLEAN_BUILD variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$DELETE_OLD_ZIP_IN_AK" != 0 ] && [ "$DELETE_OLD_ZIP_IN_AK" != 1 ]; then
            printf "\n%bIncorrect DELETE_OLD_ZIP_IN_AK variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$RECURSIVE_KERNEL_CLONE" != 0 ] && [ "$RECURSIVE_KERNEL_CLONE" != 1 ]; then
            printf "\n%bIncorrect RECURSIVE_KERNEL_CLONE variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$STANDALONE_COMPILATION" != 0 ] && [ "$STANDALONE_COMPILATION" != 1 ]; then
            printf "\n%bIncorrect STANDALONE_COMPILATION variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$APPEND_DATE" != 0 ] && [ "$APPEND_DATE" != 1 ]; then
            printf "\n%bIncorrect APPEND_DATE variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$APPEND_LINUX_VERSION" != 0 ] && [ "$APPEND_LINUX_VERSION" != 1 ]; then
            printf "\n%bIncorrect APPEND_LINUX_VERSION variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            die_22
        fi
    }

    slash_check() {
        tcd_first_char=$(printf "%s" "$TOOLCHAIN_DIR" | cut -c -1)
        tcd_last_char=$(printf "%s" "$TOOLCHAIN_DIR" | sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' | cut -c -1)
        kld_first_char=$(printf "%s" "$KERNEL_DIR" | cut -c -1)
        kld_last_char=$(printf "%s" "$KERNEL_DIR" | sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' | cut -c -1)
        kldo_first_char=$(printf "%s" "$KERNEL_OUTPUT_DIR" | cut -c -1)
        kldo_last_char=$(printf "%s" "$KERNEL_OUTPUT_DIR" | sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' | cut -c -1)

        if [ "$tcd_first_char" = "/" ]; then
            printf "\n%bRemove the first slash (/) in TOOLCHAIN_DIR variable.%b\n\n" "$red" "$darkwhite"
            die_21
        elif [ "$tcd_last_char" = "/" ]; then
            printf "\n%bRemove the last slash (/) in TOOLCHAIN_DIR variable.%b\n\n" "$red" "$darkwhite"
            die_21
        fi

        if [ "$kld_first_char" = "/" ]; then
            printf "\n%bRemove the first slash (/) in KERNEL_DIR variable.%b\n\n" "$red" "$darkwhite"
            die_21
        elif [ "$kld_last_char" = "/" ]; then
            printf "\n%bRemove the last slash (/) in KERNEL_DIR variable.%b\n\n" "$red" "$darkwhite"
            die_21
        fi

        if [ "$kldo_first_char" = "/" ]; then
            printf "\n%bRemove the first slash (/) in KERNEL_OUTPUT_DIR variable.%b\n\n" "$red" "$darkwhite"
            die_21
        elif [ "$kldo_last_char" = "/" ]; then
            printf "\n%bRemove the last slash (/) in KERNEL_OUTPUT_DIR variable.%b\n\n" "$red" "$darkwhite"
            die_21
        fi

        if [ -n "$AK_DIR" ]; then
            akd_first_char=$(printf "%s" "$AK_DIR" | cut -c -1)
            akd_last_char=$(printf "%s" "$AK_DIR" | sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' | cut -c -1)

            if [ "$akd_first_char" = "/" ]; then
                printf "\n%bRemove the first slash (/) in AK_DIR variable.%b\n\n" "$red" "$darkwhite"
                die_21
            elif [ "$akd_last_char" = "/" ]; then
                printf "\n%bRemove the last slash (/) in AK_DIR variable.%b\n\n" "$red" "$darkwhite"
                die_21
            fi
        fi

        if [ -n "$CLANG_DIR" ]; then
            cgd_first_char=$(printf "%s" "$CLANG_DIR" | cut -c -1)
            cgd_last_char=$(printf "%s" "$CLANG_DIR" | sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' | cut -c -1)

            if [ "$cgd_first_char" = "/" ]; then
                printf "\n%bRemove the first slash (/) in CLANG_DIR variable.%b\n\n" "$red" "$darkwhite"
                die_21
            elif [ "$cgd_last_char" = "/" ]; then
                printf "\n%bRemove the last slash (/) in CLANG_DIR variable.%b\n\n" "$red" "$darkwhite"
                die_21
            fi
        fi
    }

    incorrect_variables_check() {
        if [ "$KERNEL_ARCH" != "arm64" ] && [ "$KERNEL_ARCH" != "arm" ]; then
            printf "\n%bIncorrect input for KERNEL_ARCH variable.%b\n\n" "$red" "$darkwhite"
            die_21
        fi

        if [ -n "$CLANG_DIR" ] && [ "$STANDALONE_COMPILATION" = 1 ]; then
            printf "\n%bYou cannot make standalone compilation with Clang...%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ "$ZIP_BUILDER" = 1 ] && [ -z "$AK_DIR" ]; then
            printf "\n%bZip builder is enabled, but AnyKernel is not defined...%b\n\n" "$red" "$darkwhite"
            die_22
        fi
    }

    missing_and_undefined_variables_check() {
        if [ ! -d "$tc_dir" ] && [ -z "$TOOLCHAIN_REPO" ] && [ -z "$TOOLCHAIN_BRANCH" ]; then
            printf "\n%bToolchain is missing, and you did not define repo and branch variables for it.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ ! -d "$kl_dir" ] && [ -z "$KERNEL_REPO" ] && [ -z "$KERNEL_BRANCH" ]; then
            printf "\n%bKernel is missing, and you did not define repo and branch variables for it.%b\n\n" "$red" "$darkwhite"
            die_22
        fi

        if [ -n "$AK_DIR" ]; then
            if [ ! -d "$ak_dir" ] && [ -z "$AK_REPO" ] && [ -z "$AK_BRANCH" ]; then
                printf "\n%bAnyKernel is missing, and you did not define repo and branch variables for it.%b\n\n" "$red" "$darkwhite"
                die_22
            fi
        fi

        if [ -n "$CLANG_DIR" ]; then
            if [ ! -d "$cg_dir" ] && [ -z "$CLANG_REPO" ] && [ -z "$CLANG_BRANCH" ]; then
                printf "\n%bClang is missing, and you did not define repo and branch variables for it.%b\n\n" "$red" "$darkwhite"
                die_22
            fi
        fi
    }

    undefined_variables_check
    toggles_check
    slash_check
    incorrect_variables_check
    missing_and_undefined_variables_check
}

function package_checker() {

    ccache_binary() {
        if [ "$USE_CCACHE" = 1 ]; then
            if ! command -v ccache > /dev/null 2>&1; then
                printf "\n%bccache not found.%b\n\n" "$red" "$darkwhite"
                die_10
            fi
        fi
    }

    git_binary() {
        if [ -n "$AK_REPO" ] || [ -n "$AK_BRANCH" ] || \
        [ -n "$TOOLCHAIN_REPO" ] || [ -n "$TOOLCHAIN_BRANCH" ] || \
        [ -n "$CLANG_REPO" ] || [ -n "$CLANG_BRANCH" ] || \
        [ -n "$KERNEL_REPO" ] || [ -n "$KERNEL_BRANCH" ]; then
            if ! command -v git > /dev/null 2>&1; then
                printf "\n%bgit not found.%b\n\n" "$red" "$darkwhite"
                die_10
            fi
        fi
    }

    zip_binary() {
        if [ "$ZIP_BUILDER" = 1 ]; then
            if ! command -v zip > /dev/null 2>&1; then
                printf "\n%bzip not found.%b\n\n" "$red" "$darkwhite"
                die_10
            fi
        fi
    }

    ccache_binary
    git_binary
    zip_binary
}

function cloning() {

    anykernel() {
        if [ -n "$AK_DIR" ]; then
            if [ ! -d "$ak_dir" ]; then
                printf "\n%bCloning AnyKernel...%b\n" "$white" "$darkwhite"
                git clone --branch ${AK_BRANCH} --depth ${ak_clone_depth} ${AK_REPO} "${ak_dir}"
            fi
        fi
    }

    toolchain() {
        if [ ! -d "$tc_dir" ]; then
            printf "\n%bCloning the toolchain...%b\n" "$white" "$darkwhite"
            git clone --branch ${TOOLCHAIN_BRANCH} --depth ${tc_clone_depth} ${TOOLCHAIN_REPO} "${tc_dir}"
        fi
    }

    clang() {
        if [ -n "$CLANG_DIR" ]; then
            if [ ! -d "$cg_dir" ]; then
                printf "\n%bCloning Clang...%b\n" "$white" "$darkwhite"
                git clone --branch ${CLANG_BRANCH} --depth ${tc_clone_depth} ${CLANG_REPO} "${cg_dir}"
            fi
        fi
    }

    kernel() {
        if [ ! -d "$kl_dir" ]; then
            printf "\n%bCloning the kernel...%b\n" "$white" "$darkwhite"
            if [ "$RECURSIVE_KERNEL_CLONE" = 1 ]; then
                git clone --recursive --branch ${KERNEL_BRANCH} --depth ${kl_clone_depth} ${KERNEL_REPO} "${kl_dir}"
            else
                git clone --branch ${KERNEL_BRANCH} --depth ${kl_clone_depth} ${KERNEL_REPO} "${kl_dir}"
            fi
        fi
    }

    anykernel
    toolchain
    clang
    kernel
}

function choices() {

    clean_build() {
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
            elif [ -f "$sde_file" ]; then
                printf "\n%bClean from previous build?%b\n" "$white" "$darkwhite"
                select yn1 in "Yes" "No"; do
                    case $yn1 in
                        Yes )
                            cd "${kl_dir}" || die_30
                            make clean
                            make mrproper
                            break;;
                        No ) break;;
                    esac
                done
            fi
        fi
    }

    compilation_method() {
        if [ -n "$CLANG_DIR" ]; then
            clg=1
            printf "\n%bClang detected, starting compilation.%b\n" "$white" "$darkwhite"
        elif [ "$STANDALONE_COMPILATION" = 0 ]; then
            out=1
            printf "\n%bStarting output folder compilation.%b\n" "$white" "$darkwhite"
        else
            sde=1
            printf "\n%bStarting standalone compilation.%b\n" "$white" "$darkwhite"
        fi

        printf "\n"
    }

    clean_build
    compilation_method
}

function automatic_configuration() {

    set_subarch() {
        if [ "$KERNEL_ARCH" = "arm64" ]; then
            kernel_subarch=arm64
        else
            kernel_subarch=arm
        fi
    }

    get_toolchain_prefix() {
        cd "${tc_dir}"/lib/gcc || die_30
        cd -- * || die_30
        tc_prefix=$(basename "$PWD")-
    }

    ccache_path() {
        if [ "$USE_CCACHE" = 1 ]; then
            ccache_loc=$(command -v ccache)
        fi
    }

    user() {
        if [ -z "$KERNEL_BUILD_USER" ]; then
            idkme=$(id -un)
        fi
    }

    host() {
        if [ -z "$KERNEL_BUILD_HOST" ]; then
            idkmy=$(uname -n)
        fi
    }

    set_subarch
    get_toolchain_prefix
    ccache_path
    user
    host
}

function time_log_start1() {
    start1=$(date +'%s')
}

function compilation() {

    clang() {
        if [ "$clg" = 1 ]; then
            cd "${kl_dir}" || die_30

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

            if [ -n "$KERNEL_LOCALVERSION" ]; then
                export LOCALVERSION=${KERNEL_LOCALVERSION}
            fi

            export ARCH=${KERNEL_ARCH}
            export SUBARCH=${kernel_subarch}

            make O="${out_dir}" \
                ARCH=${KERNEL_ARCH} \
                ${KERNEL_DEFCONFIG}

            if [ "$USE_CCACHE" = 1 ]; then
                cpaths="${ccache_loc} ${cg_dir}/bin:${tc_dir}/bin:${PATH}"
            else
                cpaths="${cg_dir}/bin:${tc_dir}/bin:${PATH}"
            fi

            tc_paths=${cpaths} \
            make O="${out_dir}" \
                ARCH=${KERNEL_ARCH} \
                CC=${CLANG_BIN} \
                CLANG_TRIPLE=${CLANG_PREFIX} \
                CROSS_COMPILE="${tc_prefix}" \
                -j"$(nproc --all)"
        fi
    }

    output_folder() {
        if [ "$out" = 1 ]; then
            cd "${kl_dir}" || die_30

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

            if [ -n "$KERNEL_LOCALVERSION" ]; then
                export LOCALVERSION=${KERNEL_LOCALVERSION}
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
        fi
    }

    standalone() {
        if [ "$sde" = 1 ]; then
            cd "${kl_dir}" || die_30

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

            if [ -n "$KERNEL_LOCALVERSION" ]; then
                export LOCALVERSION=${KERNEL_LOCALVERSION}
            fi

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
    }

    clang
    output_folder
    standalone
}

function time_log_end1() {
    end1=$(date +'%s')
    comptime=$((end1-start1))
}

function compilation_report() {
    if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
        if [ -f "$out_kl_img" ]; then
            if [ "$STATS" = 0 ] && [ "$ZIP_BUILDER" = 0 ]; then
                printf "\n%bThe kernel is compiled successfully!%b\n\n" "$green" "$darkwhite"
            else
                printf "\n%bThe kernel is compiled successfully!%b\n" "$green" "$darkwhite"
            fi
        else
            die_40
        fi
    elif [ "$sde" = 1 ]; then
        if [ -f "$sde_kl_img" ]; then
            if [ "$STATS" = 0 ] && [ "$ZIP_BUILDER" = 0 ]; then
                printf "\n%bThe kernel is compiled successfully!%b\n\n" "$green" "$darkwhite"
            else
                printf "\n%bThe kernel is compiled successfully!%b\n" "$green" "$darkwhite"
            fi
        else
            die_40
        fi
    fi
}

function zip_builder() {

    copy_image() {
        if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
            cp "${out_kl_img}" "${ak_kl_img}"
        elif [ "$sde" = 1 ]; then
            cp "${sde_kl_img}" "${ak_kl_img}"
        fi

        printf "%bImage.gz-dtb copied.%b\n\n" "$green" "$darkwhite"
    }

    remove_old_zip() {
        if [ "$DELETE_OLD_ZIP_IN_AK" = 1 ]; then
            rm -f "${ak_dir}"/*${KERNEL_NAME}*.zip
        fi
    }

    filename() {
        kernel_linux_version=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')

        if [ -n "$CUSTOM_ZIP_NAME" ]; then
            filename="${CUSTOM_ZIP_NAME}.zip"
        else
            filename="${KERNEL_NAME}"

            if [ -n "$APPEND_VERSION" ]; then
                filename="${filename}-${APPEND_VERSION}"
            fi

            if [ "$APPEND_LINUX_VERSION" = 1 ]; then
                filename="${filename}-${kernel_linux_version}"
            fi

            if [ -n "$APPEND_ANDROID_TARGET" ]; then
                filename="${filename}-${APPEND_ANDROID_TARGET}"
            fi

            if [ "$APPEND_DATE" = 1 ]; then
                filename="${filename}-${current_date}"
            fi

            filename="${filename}.zip"
        fi
    }

    create_zip() {
        printf "%bPacking the kernel...%b\n\n" "$white" "$darkwhite"

        pushd "${ak_dir}" || die_30
            zip -FSr9 "${filename}" ./* -x .git ./*.zip README.md
        popd || die_30
    }

    copy_image
    remove_old_zip
    filename
    create_zip
}

function stats() {

    convert_bytes_func() {
        b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,P,E,Z,Y}B)
        while ((b > 1000)); do
            d="$(printf ".%02d" $((b % 1000 * 100 / 1000)))"
            b=$((b / 1000))
            (( s++ ))
        done
        echo "$b$d ${S[$s]}"
    }

    get_size_of_file_in_bytes() {
        if [ "$ZIP_BUILDER" = 1 ]; then
            byteszip=$(wc -c < "${ak_dir}"/"${filename}")
        elif [ "$out" = 1 ]; then
            bytesoutimg=$(wc -c < "${out_kl_img}")
        else
            bytessdeimg=$(wc -c < "${sde_kl_img}")
        fi
    }

    convert_bytes_of_file() {
        if [ "$ZIP_BUILDER" = 1 ]; then
            sizezip=$(convert_bytes_func "${byteszip}")
        elif [ "$out" = 1 ]; then
            sizeoutimg=$(convert_bytes_func "${bytesoutimg}")
        else
            sizesdeimg=$(convert_bytes_func "${bytessdeimg}")
        fi
    }

    localversion() {
        printf "\n"

        if [ -n "$KERNEL_LOCALVERSION" ]; then
            printf "%b> LOCALVERSION: %s\n" "$white" "$KERNEL_LOCALVERSION"
        fi
    }

    user() {
        if [ -n "$KERNEL_BUILD_USER" ]; then
            printf "%b> User: %s\n" "$white" "$KERNEL_BUILD_USER"
        else
            printf "%b> User: %s\n" "$white" "$idkme"
        fi
    }

    host() {
        if [ -n "$KERNEL_BUILD_HOST" ]; then
            printf "%b> Host: %s\n" "$white" "$KERNEL_BUILD_HOST"
        else
            printf "%b> Host: %s\n" "$white" "$idkmy"
        fi
    }

    compilation_time() {
        comptimemin=$((comptime / 60))
        comptimesec=$((comptime % 60))

        if [ "$comptimemin" = 1 ] && [ "$comptimesec" = 1 ]; then
            printf "%b> Compilation took: %d minute and %d second%b\n" "$white" "$comptimemin" "$comptimesec" "$darkwhite"
        elif [ "$comptimemin" = 1 ] && [ "$comptimesec" != 1 ]; then
            printf "%b> Compilation took: %d minute and %d seconds%b\n" "$white" "$comptimemin" "$comptimesec" "$darkwhite"
        elif [ "$comptimemin" != 1 ] && [ "$comptimesec" = 1 ]; then
            printf "%b> Compilation took: %d minutes and %d second%b\n" "$white" "$comptimemin" "$comptimesec" "$darkwhite"
        elif [ "$comptimemin" != 1 ] && [ "$comptimesec" != 1 ]; then
            printf "%b> Compilation took: %d minutes and %d seconds%b\n" "$white" "$comptimemin" "$comptimesec" "$darkwhite"
        fi
    }

    compilation_details() {
        if [ "$clg" = 1 ]; then
            if [ "$USE_CCACHE" = 1 ]; then
                printf "%b> Compilation details: out-%s-ccache\n" "$white" "$CLANG_BIN"
            else
                printf "%b> Compilation details: out-%s\n" "$white" "$CLANG_BIN"
            fi
        elif [ "$out" = 1 ]; then
            if [ "$USE_CCACHE" = 1 ]; then
                printf "%b> Compilation details: out-gcc-ccache\n" "$white"
            else
                printf "%b> Compilation details: out-gcc\n" "$white"
            fi
        elif [ "$sde" = 1 ]; then
            if [ "$USE_CCACHE" = 1 ]; then
                printf "%b> Compilation details: standalone-gcc-ccache\n" "$white"
            else
                printf "%b> Compilation details: standalone-gcc\n" "$white"
            fi
        fi
    }

    file_size() {
        if [ "$ZIP_BUILDER" = 1 ]; then
            printf "%b> Zip size: %s\n" "$white" "$sizezip"
        elif [ "$out" = 1 ]; then
            printf "%b> Image size: %s\n" "$white" "$sizeoutimg"
        else
            printf "%b> Image size: %s\n" "$white" "$sizesdeimg"
        fi
    }

    file_location() {
        if [ "$ZIP_BUILDER" = 1 ]; then
            printf "%b> Zip location: %s/%s\n\n" "$white" "$ak_dir" "$filename"
        elif [ "$out" = 1 ]; then
            printf "%b> Image location: %s\n\n" "$white" "$out_kl_img"
        else
            printf "%b> Image location: %s\n\n" "$white" "$sde_kl_img"
        fi
    }

    get_size_of_file_in_bytes
    convert_bytes_of_file
    localversion
    user
    host
    compilation_time
    compilation_details
    file_size
    file_location
}

variables
additional_variables
die_codes
configuration_checker
package_checker
cloning
choices
automatic_configuration
time_log_start1
compilation
time_log_end1
compilation_report

if [ "$ZIP_BUILDER" = 1 ]; then
    zip_builder
fi

if [ "$STATS" = 1 ]; then
    stats
fi
