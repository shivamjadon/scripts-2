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

function variables() {

    ESSENTIAL_VARIABLES() {
        TOOLCHAIN_DIR=
        KERNEL_DIR=
        KERNEL_OUTPUT_DIR=
        KERNEL_DEFCONFIG=
        KERNEL_ARCH=
    }

    SCRIPT_VARIABLES() {
        USE_CCACHE=0
        ZIP_BUILDER=0
        RECURSIVE_KERNEL_CLONE=0
        NORMAL_COMPILATION=0
    }

    OPTIONAL_VARIABLES() {

        anykernel() {
            ak_essential_variables() {
                AK_DIR=
                KERNEL_NAME=
            }
            ak_remote_variables() {
                # NOTE: Shallow clone, i.e. limited history. Not recommended for any commit work.
                AK_REPO=
                AK_BRANCH=
            }
            ak_zip_filename_variables() {
                APPEND_VERSION=
                APPEND_DEVICE=
                APPEND_ANDROID_TARGET=
                APPEND_DATE=0
                CUSTOM_ZIP_NAME=
            }
        }

        toolchain() {
            tc_remote_variables() {
                # NOTE: Shallow clone, i.e. limited history. Not recommended for any commit work.
                TOOLCHAIN_REPO=
                TOOLCHAIN_BRANCH=
            }
        }

        clang() {
            cg_essential_variables() {
                CLANG_DIR=
                CLANG_BIN=
                CLANG_PREFIX=
            }
            cg_remote_variables() {
                # NOTE: Shallow clone, i.e. limited history. Not recommended for any commit work.
                CLANG_REPO=
                CLANG_BRANCH=
            }
        }

        kernel() {
            kl_remote_variables() {
                # NOTE: Shallow clone, i.e. limited history. Not recommended for any commit work.
                KERNEL_REPO=
                KERNEL_BRANCH=
            }
            kl_options() {
                KERNEL_BUILD_USER=
                KERNEL_BUILD_HOST=
                KERNEL_LOCALVERSION=
            }
        }

        miscellaneous() {
            ms_sync_variables() {
                # NOTE: True sync. Any local changes are discarded. All remote changes are pulled.
                SYNC_AK_DIR=0
                SYNC_TC_DIR=0
                SYNC_KERNEL_DIR=0
            }
        }
    }
}

function automatic_configuration() {

    import_variables_0() {
        ESSENTIAL_VARIABLES
        SCRIPT_VARIABLES
        OPTIONAL_VARIABLES

        import_variables_1() {
            anykernel
            toolchain
            clang
            kernel
            miscellaneous

            import_variables_2() {
                ak_essential_variables
                ak_remote_variables
                ak_zip_filename_variables
                tc_remote_variables
                cg_essential_variables
                cg_remote_variables
                kl_remote_variables
                kl_options
                ms_sync_variables
            }

            import_variables_2
        }

        import_variables_1
    }

    tc_dir_input() {
        if [[ ${TOOLCHAIN_DIR} == "/home/"* ]] || [[ ${TOOLCHAIN_DIR} == "$HOME/"* ]]; then
            TOOLCHAIN_DIR=${TOOLCHAIN_DIR#*/}
            TOOLCHAIN_DIR=${TOOLCHAIN_DIR#*/}
            TOOLCHAIN_DIR=${TOOLCHAIN_DIR#*/}
        elif [[ ${TOOLCHAIN_DIR} == "home/"* ]]; then
            TOOLCHAIN_DIR=${TOOLCHAIN_DIR#*/}
            TOOLCHAIN_DIR=${TOOLCHAIN_DIR#*/}
        fi

        if [[ ${TOOLCHAIN_DIR} == "/"* ]]; then
            TOOLCHAIN_DIR=${TOOLCHAIN_DIR#*/}
        fi

        if [[ ${TOOLCHAIN_DIR} == *"/" ]]; then
            TOOLCHAIN_DIR=${TOOLCHAIN_DIR%?}
        fi
    }

    kl_dir_input() {
        if [[ ${KERNEL_DIR} == "/home/"* ]] || [[ ${KERNEL_DIR} == "/$HOME/"* ]]; then
            KERNEL_DIR=${KERNEL_DIR#*/}
            KERNEL_DIR=${KERNEL_DIR#*/}
            KERNEL_DIR=${KERNEL_DIR#*/}
        elif [[ ${KERNEL_DIR} == "home/"* ]] || [[ ${KERNEL_DIR} == "$HOME/"* ]]; then
            KERNEL_DIR=${KERNEL_DIR#*/}
            KERNEL_DIR=${KERNEL_DIR#*/}
        fi

        if [[ ${KERNEL_DIR} == "/"* ]]; then
            KERNEL_DIR=${KERNEL_DIR#*/}
        fi

        if [[ ${KERNEL_DIR} == *"/" ]]; then
            KERNEL_DIR=${KERNEL_DIR%?}
        fi
    }

    kl_out_dir_input() {
        if [[ ${KERNEL_OUTPUT_DIR} == "/home/"* ]] || [[ ${KERNEL_OUTPUT_DIR} == "/$HOME/"* ]]; then
            KERNEL_OUTPUT_DIR=${KERNEL_OUTPUT_DIR#*/}
            KERNEL_OUTPUT_DIR=${KERNEL_OUTPUT_DIR#*/}
            KERNEL_OUTPUT_DIR=${KERNEL_OUTPUT_DIR#*/}
        elif [[ ${KERNEL_OUTPUT_DIR} == "home/"* ]] || [[ ${KERNEL_OUTPUT_DIR} == "$HOME/"* ]]; then
            KERNEL_OUTPUT_DIR=${KERNEL_OUTPUT_DIR#*/}
            KERNEL_OUTPUT_DIR=${KERNEL_OUTPUT_DIR#*/}
        fi

        if [[ ${KERNEL_OUTPUT_DIR} == "/"* ]]; then
            KERNEL_OUTPUT_DIR=${KERNEL_OUTPUT_DIR#*/}
        fi

        if [[ ${KERNEL_OUTPUT_DIR} == *"/" ]]; then
            KERNEL_OUTPUT_DIR=${KERNEL_OUTPUT_DIR%?}
        fi
    }

    ak_dir_input() {
        if [[ ${AK_DIR} == "/home/"* ]] || [[ ${AK_DIR} == "/$HOME/"* ]]; then
            AK_DIR=${AK_DIR#*/}
            AK_DIR=${AK_DIR#*/}
            AK_DIR=${AK_DIR#*/}
        elif [[ ${AK_DIR} == "home/"* ]] || [[ ${AK_DIR} == "$HOME/"* ]]; then
            AK_DIR=${AK_DIR#*/}
            AK_DIR=${AK_DIR#*/}
        fi

        if [[ ${AK_DIR} == "/"* ]]; then
            AK_DIR=${AK_DIR#*/}
        fi

        if [[ ${AK_DIR} == *"/" ]]; then
            AK_DIR=${AK_DIR%?}
        fi
    }

    cg_dir_input() {
        if [[ ${CLANG_DIR} == "/home/"* ]] || [[ ${CLANG_DIR} == "/$HOME/"* ]]; then
            CLANG_DIR=${CLANG_DIR#*/}
            CLANG_DIR=${CLANG_DIR#*/}
            CLANG_DIR=${CLANG_DIR#*/}
        elif [[ ${CLANG_DIR} == "home/"* ]] || [[ ${CLANG_DIR} == "$HOME/"* ]]; then
            CLANG_DIR=${CLANG_DIR#*/}
            CLANG_DIR=${CLANG_DIR#*/}
        fi

        if [[ ${CLANG_DIR} == "/"* ]]; then
            CLANG_DIR=${CLANG_DIR#*/}
        fi

        if [[ ${CLANG_DIR} == *"/" ]]; then
            CLANG_DIR=${CLANG_DIR%?}
        fi
    }

    defconfig_input() {
        if [[ ${KERNEL_DEFCONFIG} == "/"* ]]; then
            KERNEL_DEFCONFIG=${KERNEL_DEFCONFIG#*/}
        fi

        if [[ ${KERNEL_DEFCONFIG} == *"/" ]]; then
            KERNEL_DEFCONFIG=${KERNEL_DEFCONFIG%?}
        fi

        if [[ ${KERNEL_DEFCONFIG} == *"/"* ]]; then
            KERNEL_DEFCONFIG=${KERNEL_DEFCONFIG##*/}
        fi
    }

    import_variables_0
    tc_dir_input
    kl_dir_input
    kl_out_dir_input

    if [ -n "$AK_DIR" ]; then
        ak_dir_input
    fi

    if [ -n "$CLANG_DIR" ]; then
        cg_dir_input
    fi

    defconfig_input
}

function automatic_variables() {

    colors() {
        red='\033[1;31m'
        green='\033[1;32m'
        white='\033[1;37m'
        darkwhite='\033[0;37m'
        cyan='\033[1;36m'
    }

    cosmetic_variables() {
        akc=nah
        tcc=nope
        cgc=no
        klc=noway
        clg=ahno
        out=justno
        dry=seemsno
        ncf=maybeno
    }

    clone_depth() {
        ak_clone_depth=1
        tc_clone_depth=1
        kl_clone_depth=10
    }

    persistent_cache() {
        cache_file_0="$HOME"/.bkscache0
        cache_file_1="$HOME"/.bkscache1
    }

    location_shortcuts() {

        config_locations() {
            kl_config="$HOME"/${KERNEL_DIR}/arch/arm64/configs/${KERNEL_DEFCONFIG}
            kl_vendor_config="$HOME"/${KERNEL_DIR}/arch/arm64/configs/vendor/${KERNEL_DEFCONFIG}
            kl_make_config=${KERNEL_DEFCONFIG}
            kl_make_vendor_config=vendor/${KERNEL_DEFCONFIG}

            prepare_config_location() {
                if [ ! -f "$kl_config" ]; then
                    if [ -f "$kl_vendor_config" ]; then
                        kl_make_config=${kl_make_vendor_config}
                    else
                        ncf=1
                    fi
                fi
            }

            prepare_config_location
        }

        kl_locations() {
            kl_dir="$HOME"/${KERNEL_DIR}
            kl_out_dir="$HOME"/${KERNEL_OUTPUT_DIR}
            kl_out_img="$HOME"/${KERNEL_OUTPUT_DIR}/arch/${KERNEL_ARCH}/boot/Image.gz
            kl_nml_img="$HOME"/${KERNEL_DIR}/arch/${KERNEL_ARCH}/boot/Image.gz
            kl_out_img_dtb="$HOME"/${KERNEL_OUTPUT_DIR}/arch/${KERNEL_ARCH}/boot/Image.gz-dtb
            kl_nml_img_dtb="$HOME"/${KERNEL_DIR}/arch/${KERNEL_ARCH}/boot/Image.gz-dtb
            kl_conf_object="$HOME"/${KERNEL_DIR}/scripts/kconfig/conf.o
        }

        ak_locations() {
            ak_dir="$HOME"/${AK_DIR}
            ak_kl_img="$HOME"/${AK_DIR}/Image.gz
            ak_kl_img_dtb="$HOME"/${AK_DIR}/Image.gz-dtb
        }

        tc_locations() {
            tc_dir="$HOME"/${TOOLCHAIN_DIR}
        }

        cg_locations() {
            cg_dir="$HOME"/${CLANG_DIR}
        }

        config_locations
        kl_locations
        ak_locations
        tc_locations
        cg_locations
    }

    stats_options() {
        convert_bytes_to_ibi=0
    }

    zip_builder_options() {
        aggressive_zip_rm=1
        copy_dtb_image=1
    }

    date_call() {
        current_date=$(date +'%Y%m%d')
    }

    colors
    cosmetic_variables
    clone_depth
    persistent_cache
    location_shortcuts
    stats_options
    zip_builder_options
    date_call
}

function environment_check() {

    bash_check() {
        local bash_ver
        local bash_ver_cut
        bash_ver=${BASH_VERSION}
        bash_ver_cut=$(printf "%s" "$bash_ver" | cut -c -1)

        if [ "$bash_ver_cut" = "2" ] || [ "$bash_ver_cut" = "3" ]; then
            printf "\n%bThis script requires bash 4+%b\n\n" "$red" "$darkwhite"
            exit 1
        fi
    }

    root_check() {
        if [ $EUID = 0 ]; then
            printf "\n%bYou should not run this script as root.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi
    }

    bash_check
    root_check
}

function helpers() {

    command_available() {
        local get_command
        get_command=$(printf "%s" "$1")

        if command -v "${get_command}" > /dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    }

    convert_bytes() {
        local bytes
        local delimeter
        local s
        local S
        bytes=${1:-0};
        delimeter=''
        s=0

        if [ "$convert_bytes_to_ibi" = 0 ]; then
            S=(Bytes {K,M,G}B)
        else
            S=(Bytes {K,M,G}iB)
        fi

        if [ "$convert_bytes_to_ibi" = 0 ]; then
            while ((bytes > 1000)); do
                delimeter="$(printf ".%02d" $((bytes % 1000 * 100 / 1000)))"
                bytes=$((bytes / 1000))
                (( s++ ))
            done
        else
            while ((bytes > 1024)); do
                delimeter="$(printf ".%02d" $((bytes % 1024 * 100 / 1024)))"
                bytes=$((bytes / 1024))
                (( s++ ))
            done
        fi

        echo "$bytes$delimeter ${S[$s]}"
    }

    remove_every_zip() {
        local lsexit
        local get_dir
        get_dir=$(printf "%s" "$1")

        ls "${get_dir}"/*.zip > /dev/null 2>&1
        lsexit=$(printf "%d" "$?")

        if [ "$lsexit" = 2 ]; then
            return 2
        fi

        if [ "$lsexit" = 0 ]; then
            rm -rf "${get_dir}"/*.zip
        fi
    }
}

function traps() {

    abort() {
        printf "\n\n%bThe script was forcefully aborted.%b\n\n" "$white" "$darkwhite"
        exit 130
    }

    trap abort SIGINT
}

function die_codes() {

    die_20() {
        printf "\n%bYou changed one or more variables' names.%b\n\n" "$red" "$darkwhite"
        exit 20
    }

    die_21() {
        printf "\n%bYou did not define all essential variables for the current configuration.%b\n\n" "$red" "$darkwhite"
        exit 21
    }

    die_30() {
        printf "\n%bUnexpected path issue.%b\n\n" "$red" "$darkwhite"
        exit 30
    }

    die_31() {
        printf "\n%bThe cloning of a source failed.%b\n\n" "$red" "$darkwhite"
        exit 31
    }

    die_40() {
        printf "\n%bThe kernel was not compiled correctly.%b\n\n" "$red" "$darkwhite"
        exit 40
    }

    die_41() {
        printf "\n%bImage.gz-dtb is selected to be copied, but only Image.gz was compiled.%b\n\n" "$red" "$darkwhite"
        exit 41
    }
}

function configuration_checker() {

    changed_variables() {
        if [ ! -v TOOLCHAIN_DIR ] || [ ! -v KERNEL_DIR ] || \
        [ ! -v KERNEL_OUTPUT_DIR ] || [ ! -v KERNEL_DEFCONFIG ] || \
        [ ! -v KERNEL_ARCH ]; then
            die_20
        fi

        if [ ! -v USE_CCACHE ] || [ ! -v ZIP_BUILDER ] || \
        [ ! -v RECURSIVE_KERNEL_CLONE ] || [ ! -v NORMAL_COMPILATION ]; then
            die_20
        fi

        if [ ! -v AK_DIR ] || [ ! -v KERNEL_NAME ] || \
        [ ! -v AK_REPO ] || [ ! -v AK_BRANCH ] || \
        [ ! -v APPEND_VERSION ] || [ ! -v APPEND_DEVICE ] || \
        [ ! -v APPEND_ANDROID_TARGET ] || [ ! -v APPEND_DATE ] || \
        [ ! -v CUSTOM_ZIP_NAME ]; then
            die_20
        fi

        if [ ! -v TOOLCHAIN_REPO ] || [ ! -v TOOLCHAIN_BRANCH ]; then
            die_20
        fi

        if [ ! -v CLANG_DIR ] || [ ! -v CLANG_BIN ] || \
        [ ! -v CLANG_PREFIX ] || [ ! -v CLANG_REPO ] || \
        [ ! -v CLANG_BRANCH ]; then
            die_20
        fi

        if [ ! -v KERNEL_REPO ] || [ ! -v KERNEL_BRANCH ] || \
        [ ! -v KERNEL_BUILD_USER ] || [ ! -v KERNEL_BUILD_HOST ] || \
        [ ! -v KERNEL_LOCALVERSION ]; then
            die_20
        fi

        if [ ! -v SYNC_AK_DIR ] || [ ! -v SYNC_TC_DIR ] || \
        [ ! -v SYNC_KERNEL_DIR ]; then
            die_20
        fi
    }

    undefined_variables() {
        if [ -z "$TOOLCHAIN_DIR" ] || [ -z "$KERNEL_DIR" ] || \
        [ -z "$KERNEL_OUTPUT_DIR" ] || [ -z "$KERNEL_DEFCONFIG" ] || \
        [ -z "$KERNEL_ARCH" ]; then
            die_21
        fi

        if [ -n "$AK_DIR" ]; then
            if [ -z "$KERNEL_NAME" ]; then
                die_21
            fi
        fi

        if [ -n "$CLANG_DIR" ]; then
            if [ -z "$CLANG_BIN" ]; then
                die_21
            fi

            if [ -z "$CLANG_PREFIX" ]; then
                printf "\n%bYou did not define CLANG_PREFIX (CLANG_TRIPLE), and that is okay, %b" "$white" "$darkwhite"
                printf "%bbut if you are using AOSP's Clang, then stop this compilation and define it.%b" "$white" "$darkwhite"
                printf "\n%bTIP: aarch64-linux-gnu-%b\n" "$white" "$darkwhite"
            fi
        fi
    }

    missing_variables() {
        if [ ! -d "$tc_dir" ] && [ -z "$TOOLCHAIN_REPO" ] && [ -z "$TOOLCHAIN_BRANCH" ]; then
            printf "\n%bToolchain is missing, and you did not define repo and branch variables for it.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ ! -d "$kl_dir" ] && [ -z "$KERNEL_REPO" ] && [ -z "$KERNEL_BRANCH" ]; then
            printf "\n%bKernel is missing, and you did not define repo and branch variables for it.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ -n "$AK_DIR" ]; then
            if [ ! -d "$ak_dir" ] && [ -z "$AK_REPO" ] && [ -z "$AK_BRANCH" ]; then
                printf "\n%bAnyKernel is missing, and you did not define repo and branch variables for it.%b\n\n" "$red" "$darkwhite"
                exit 1
            fi
        fi

        if [ -n "$CLANG_DIR" ]; then
            if [ ! -d "$cg_dir" ] && [ -z "$CLANG_REPO" ] && [ -z "$CLANG_BRANCH" ]; then
                printf "\n%bClang is missing, and you did not define repo and branch variables for it.%b\n\n" "$red" "$darkwhite"
                exit 1
            fi
        fi
    }

    incorrect_variables() {
        if [ "$KERNEL_ARCH" != "arm64" ] && [ "$KERNEL_ARCH" != "arm" ]; then
            printf "\n%bIncorrect input for KERNEL_ARCH variable.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$ZIP_BUILDER" = 1 ] && [ -z "$AK_DIR" ]; then
            printf "\n%bZip builder is enabled, but AK directory is not defined...%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ -n "$CLANG_DIR" ] && [ "$NORMAL_COMPILATION" = 1 ]; then
            printf "\n%bYou cannot do normal compilation with Clang.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$SYNC_AK_DIR" = 1 ] && [ -z "$AK_DIR" ]; then
            printf "\n%bSync for AK is enabled, but AK directory is not defined...%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$ncf" = 1 ]; then
            printf "\n%bPlease put your defconfig in /configs or /configs/vendor%b\n\n" "$red" "$darkwhite"
            exit 1
        fi
    }

    check_the_toggles() {
        if [ "$USE_CCACHE" != 0 ] && [ "$USE_CCACHE" != 1 ]; then
            printf "\n%bIncorrect USE_CCACHE variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$ZIP_BUILDER" != 0 ] && [ "$ZIP_BUILDER" != 1 ]; then
            printf "\n%bIncorrect ZIP_BUILDER variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$RECURSIVE_KERNEL_CLONE" != 0 ] && [ "$RECURSIVE_KERNEL_CLONE" != 1 ]; then
            printf "\n%bIncorrect RECURSIVE_KERNEL_CLONE variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$NORMAL_COMPILATION" != 0 ] && [ "$NORMAL_COMPILATION" != 1 ]; then
            printf "\n%bIncorrect NORMAL_COMPILATION variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$APPEND_DATE" != 0 ] && [ "$APPEND_DATE" != 1 ]; then
            printf "\n%bIncorrect APPEND_DATE variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$SYNC_AK_DIR" != 0 ] && [ "$SYNC_AK_DIR" != 1 ]; then
            printf "\n%bIncorrect SYNC_AK_DIR variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$SYNC_TC_DIR" != 0 ] && [ "$SYNC_TC_DIR" != 1 ]; then
            printf "\n%bIncorrect SYNC_TC_DIR variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ "$SYNC_KERNEL_DIR" != 0 ] && [ "$SYNC_KERNEL_DIR" != 1 ]; then
            printf "\n%bIncorrect SYNC_KERNEL_DIR variable, only 0 or 1 is allowed as input for toggles.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi
    }

    changed_variables
    undefined_variables
    missing_variables
    incorrect_variables
    check_the_toggles
}

function package_checker() {

    ccache_binary() {
        if [ "$USE_CCACHE" = 1 ]; then
            if ! command_available ccache; then
                printf "\n%bccache not found.%b\n\n" "$red" "$darkwhite"

                if command_available sudo; then
                    if command_available apt; then
                        printf "%bTIP: sudo apt install ccache%b\n\n" "$white" "$darkwhite"
                    elif command_available pacman; then
                        printf "%bTIP: sudo pacman -S ccache%b\n\n" "$white" "$darkwhite"
                    elif command_available dnf; then
                        printf "%bTIP: sudo dnf install ccache%b\n\n" "$white" "$darkwhite"
                    elif command_available zypper; then
                        printf "%bTIP: sudo zypper install ccache%b\n\n" "$white" "$darkwhite"
                    elif command_available emerge; then
                        printf "%bTIP: sudo emerge -a ccache%b\n\n" "$white" "$darkwhite"
                    fi
                else
                    if command_available apt; then
                        printf "%bTIP: su root -c 'apt install ccache'%b\n\n" "$white" "$darkwhite"
                    elif command_available pacman; then
                        printf "%bTIP: su root -c 'pacman -S ccache'%b\n\n" "$white" "$darkwhite"
                    elif command_available dnf; then
                        printf "%bTIP: su root -c 'dnf install ccache'%b\n\n" "$white" "$darkwhite"
                    elif command_available zypper; then
                        printf "%bTIP: su root -c 'zypper install ccache'%b\n\n" "$white" "$darkwhite"
                    elif command_available emerge; then
                        printf "%bTIP: su root -c 'emerge -a ccache'%b\n\n" "$white" "$darkwhite"
                    fi
                fi

                exit 1
            fi
        fi
    }

    git_binary() {
        if [ -n "$AK_REPO" ] || [ -n "$AK_BRANCH" ] || \
        [ -n "$TOOLCHAIN_REPO" ] || [ -n "$TOOLCHAIN_BRANCH" ] || \
        [ -n "$CLANG_REPO" ] || [ -n "$CLANG_BRANCH" ] || \
        [ -n "$KERNEL_REPO" ] || [ -n "$KERNEL_BRANCH" ] || \
        [ "$SYNC_AK_DIR" = 1 ] || [ "$SYNC_TC_DIR" = 1 ] || \
        [ "$SYNC_KERNEL_DIR" = 1 ]; then
            if ! command_available git; then
                printf "\n%bgit not found.%b\n\n" "$red" "$darkwhite"

                if command_available sudo; then
                    if command_available apt; then
                        printf "%bTIP: sudo apt install git%b\n\n" "$white" "$darkwhite"
                    elif command_available pacman; then
                        printf "%bTIP: sudo pacman -S git%b\n\n" "$white" "$darkwhite"
                    elif command_available dnf; then
                        printf "%bTIP: sudo dnf install git%b\n\n" "$white" "$darkwhite"
                    elif command_available zypper; then
                        printf "%bTIP: sudo zypper install git%b\n\n" "$white" "$darkwhite"
                    elif command_available emerge; then
                        printf "%bTIP: sudo emerge -a git%b\n\n" "$white" "$darkwhite"
                    fi
                else
                    if command_available apt; then
                        printf "%bTIP: su root -c 'apt install git'%b\n\n" "$white" "$darkwhite"
                    elif command_available pacman; then
                        printf "%bTIP: su root -c 'pacman -S git'%b\n\n" "$white" "$darkwhite"
                    elif command_available dnf; then
                        printf "%bTIP: su root -c 'dnf install git'%b\n\n" "$white" "$darkwhite"
                    elif command_available zypper; then
                        printf "%bTIP: su root -c 'zypper install git'%b\n\n" "$white" "$darkwhite"
                    elif command_available emerge; then
                        printf "%bTIP: su root -c 'emerge -a git'%b\n\n" "$white" "$darkwhite"
                    fi
                fi

                exit 1
            fi
        fi
    }

    zip_binary() {
        if [ "$ZIP_BUILDER" = 1 ]; then
            if ! command_available zip; then
                printf "\n%bzip not found.%b\n\n" "$red" "$darkwhite"

                if command_available sudo; then
                    if command_available apt; then
                        printf "%bTIP: sudo apt install zip%b\n\n" "$white" "$darkwhite"
                    elif command_available pacman; then
                        printf "%bTIP: sudo pacman -S zip%b\n\n" "$white" "$darkwhite"
                    elif command_available dnf; then
                        printf "%bTIP: sudo dnf install zip%b\n\n" "$white" "$darkwhite"
                    elif command_available zypper; then
                        printf "%bTIP: sudo zypper install zip%b\n\n" "$white" "$darkwhite"
                    elif command_available emerge; then
                        printf "%bTIP: sudo emerge -a zip%b\n\n" "$white" "$darkwhite"
                    fi
                else
                    if command_available apt; then
                        printf "%bTIP: su root -c 'apt install zip'%b\n\n" "$white" "$darkwhite"
                    elif command_available pacman; then
                        printf "%bTIP: su root -c 'pacman -S zip'%b\n\n" "$white" "$darkwhite"
                    elif command_available dnf; then
                        printf "%bTIP: su root -c 'dnf install zip'%b\n\n" "$white" "$darkwhite"
                    elif command_available zypper; then
                        printf "%bTIP: su root -c 'zypper install zip'%b\n\n" "$white" "$darkwhite"
                    elif command_available emerge; then
                        printf "%bTIP: su root -c 'emerge -a zip'%b\n\n" "$white" "$darkwhite"
                    fi
                fi

                exit 1
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
                akc=1
                printf "\n%bStarting clone of AK with depth %d...%b\n" "$white" "$ak_clone_depth" "$darkwhite"
                git clone --branch "${AK_BRANCH}" --depth "${ak_clone_depth}" "${AK_REPO}" "${ak_dir}"
            fi
        fi
    }

    toolchain() {
        if [ ! -d "$tc_dir" ]; then
            tcc=1
            printf "\n%bStarting clone of the toolchain with depth %d...%b\n" "$white" "$tc_clone_depth" "$darkwhite"
            git clone --branch "${TOOLCHAIN_BRANCH}" --depth "${tc_clone_depth}" "${TOOLCHAIN_REPO}" "${tc_dir}"
        fi
    }

    clang() {
        if [ -n "$CLANG_DIR" ]; then
            if [ ! -d "$cg_dir" ]; then
                cgc=1
                printf "\n%bStarting clone of Clang with depth %d...%b\n" "$white" "$tc_clone_depth" "$darkwhite"
                git clone --branch "${CLANG_BRANCH}" --depth "${tc_clone_depth}" "${CLANG_REPO}" "${cg_dir}"
            fi
        fi
    }

    kernel() {
        if [ ! -d "$kl_dir" ]; then
            klc=1
            printf "\n%bStarting clone of the kernel with depth %d...%b\n" "$white" "$kl_clone_depth" "$darkwhite"
            if [ "$RECURSIVE_KERNEL_CLONE" = 1 ]; then
                git clone --recursive --branch "${KERNEL_BRANCH}" --depth "${kl_clone_depth}" "${KERNEL_REPO}" "${kl_dir}"
            else
                git clone --branch "${KERNEL_BRANCH}" --depth "${kl_clone_depth}" "${KERNEL_REPO}" "${kl_dir}"
            fi
        fi
    }

    check_directories() {
        if [ -n "$AK_DIR" ]; then
            if [ ! -d "$ak_dir" ]; then
                die_31
            fi
        fi

        if [ ! -d "$tc_dir" ]; then
            die_31
        fi

        if [ -n "$CLANG_DIR" ]; then
            if [ ! -d "$cg_dir" ]; then
                die_31
            fi
        fi

        if [ ! -d "$kl_dir" ]; then
            die_31
        fi
    }

    sync_directories() {
        if [ "$SYNC_AK_DIR" = 1 ]; then
            if [ "$akc" != 1 ]; then
                printf "\n%bStarting sync of AK source...%b\n" "$white" "$darkwhite"
                cd "${ak_dir}" || die_30
                git reset --hard "@{upstream}"
                git clean -fd
                git pull --rebase=preserve
            fi
        fi

        if [ "$SYNC_TC_DIR" = 1 ]; then
            if [ "$tcc" != 1 ]; then
                printf "\n%bStarting sync of the toolchain source...%b\n" "$white" "$darkwhite"
                cd "${tc_dir}" || die_30
                git reset --hard "@{upstream}"
                git clean -fd
                git pull --rebase=preserve
            fi

            if [ -n "$CLANG_DIR" ]; then
                if [ "$cgc" != 1 ]; then
                    printf "\n%bStarting sync of Clang source...%b\n" "$white" "$darkwhite"
                    cd "${cg_dir}" || die_30
                    git reset --hard "@{upstream}"
                    git clean -fd
                    git pull --rebase=preserve
                fi
            fi
        fi

        if [ "$SYNC_KERNEL_DIR" = 1 ]; then
            if [ "$klc" != 1 ]; then
                printf "\n%bStarting sync of the kernel source...%b\n" "$white" "$darkwhite"
                cd "${kl_dir}" || die_30
                git reset --hard "@{upstream}"
                git clean -fd
                git pull --rebase=preserve
            fi
        fi
    }

    anykernel
    toolchain
    clang
    kernel
    check_directories
    sync_directories
}

function choices() {

    compilation_method() {
        if [ -n "$CLANG_DIR" ]; then
            clg=1
            printf "\n%bClang detected, starting compilation.%b\n\n" "$white" "$darkwhite"
        elif [ "$NORMAL_COMPILATION" = 0 ]; then
            out=1
            printf "\n%bStarting output folder compilation.%b\n\n" "$white" "$darkwhite"
        else
            printf "\n%bStarting normal compilation.%b\n\n" "$white" "$darkwhite"
        fi
    }

    build_type() {
        if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
            if [ -d "$kl_out_dir" ]; then
                dry=1
            fi
        else
            if [ -f "$kl_conf_object" ]; then
                dry=1
            fi
        fi
    }

    compilation_method
    build_type
}

function pre_compilation_setup() {

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
            get_username=$(id -un)
        fi
    }

    host() {
        if [ -z "$KERNEL_BUILD_HOST" ]; then
            get_hostname=$(uname -n)
        fi
    }

    set_subarch
    get_toolchain_prefix
    ccache_path
    user
    host
}

function pre_compilation_work() {
    start1=$(date +'%s')
}

function compilation() {

    clang() {
        cd "${kl_dir}" || die_30

        if [ "$USE_CCACHE" = 1 ]; then
            paths="${ccache_loc}:${cg_dir}/bin:${tc_dir}/bin:${PATH}"
        else
            paths="${cg_dir}/bin:${tc_dir}/bin:${PATH}"
        fi

        if [ -n "$KERNEL_BUILD_USER" ]; then
            export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
        else
            export KBUILD_BUILD_USER=${get_username}
        fi

        if [ -n "$KERNEL_BUILD_HOST" ]; then
            export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
        else
            export KBUILD_BUILD_HOST=${get_hostname}
        fi

        if [ -n "$KERNEL_LOCALVERSION" ]; then
            export LOCALVERSION=${KERNEL_LOCALVERSION}
        fi

        export ARCH=${KERNEL_ARCH}
        export SUBARCH=${kernel_subarch}

        make O="${kl_out_dir}" \
            ARCH="${KERNEL_ARCH}" \
            "${kl_make_config}"

        PATH="${paths}" \
        make O="${kl_out_dir}" \
            ARCH="${KERNEL_ARCH}" \
            CC="${CLANG_BIN}" \
            CLANG_TRIPLE="${CLANG_PREFIX}" \
            CROSS_COMPILE="${tc_prefix}" \
            -j"$(nproc --all)"

        makeexit1=$(printf "%d" "$?")
    }

    output_folder() {
        cd "${kl_dir}" || die_30

        if [ -n "$KERNEL_BUILD_USER" ]; then
            export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
        else
            export KBUILD_BUILD_USER=${get_username}
        fi

        if [ -n "$KERNEL_BUILD_HOST" ]; then
            export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
        else
            export KBUILD_BUILD_HOST=${get_hostname}
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

        make O="${kl_out_dir}" \
            ARCH="${KERNEL_ARCH}" \
            "${kl_make_config}"

        make O="${kl_out_dir}" \
            ARCH="${KERNEL_ARCH}" \
            -j"$(nproc --all)"

        makeexit2=$(printf "%d" "$?")
    }

    normal() {
        cd "${kl_dir}" || die_30

        if [ -n "$KERNEL_BUILD_USER" ]; then
            export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
        else
            export KBUILD_BUILD_USER=${get_username}
        fi

        if [ -n "$KERNEL_BUILD_HOST" ]; then
            export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
        else
            export KBUILD_BUILD_HOST=${get_hostname}
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

        make "${kl_make_config}"

        CROSS_COMPILE=${CROSS_COMPILE} make -j"$(nproc --all)"

        makeexit3=$(printf "%d" "$?")
    }

    if [ "$clg" = 1 ]; then
        clang
    elif [ "$out" = 1 ]; then
        output_folder
    else
        normal
    fi
}

function post_compilation_work() {
    end1=$(date +'%s')
    compilation_time=$((end1-start1))
}

function compilation_report() {
    if [ "$clg" = 1 ]; then
        if [ "$makeexit1" != 0 ]; then
            die_40
        fi
    elif [ "$out" = 1 ]; then
        if [ "$makeexit2" != 0 ]; then
            die_40
        fi
    else
        if [ "$makeexit3" != 0 ]; then
            die_40
        fi
    fi

    if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
        if [ -f "$kl_out_img" ]; then
            printf "\n%bThe kernel is compiled successfully!%b\n\n" "$green" "$darkwhite"
        else
            die_40
        fi
    else
        if [ -f "$kl_nml_img" ]; then
            printf "\n%bThe kernel is compiled successfully!%b\n\n" "$green" "$darkwhite"
        else
            die_40
        fi
    fi
}

function stats() {

    get_bytes_of_images() {
        if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
            kl_out_img_bytes=$(wc -c < "${kl_out_img}")

            if [ -f "$kl_out_img_dtb" ]; then
                kl_out_img_dtb_bytes=$(wc -c < "${kl_out_img_dtb}")
            fi
        else
            kl_nml_img_bytes=$(wc -c < "${kl_nml_img}")

            if [ -f "$kl_nml_img_dtb" ]; then
                kl_nml_img_dtb_bytes=$(wc -c < "${kl_nml_img_dtb}")
            fi
        fi
    }

    convert_bytes_of_images() {
        if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
            kl_out_img_size=$(convert_bytes "${kl_out_img_bytes}")

            if [ -f "$kl_out_img_dtb" ]; then
                kl_out_img_dtb_size=$(convert_bytes "${kl_out_img_dtb_bytes}")
            fi
        else
            kl_nml_img_size=$(convert_bytes "${kl_nml_img_bytes}")

            if [ -f "$kl_nml_img_dtb" ]; then
                kl_nml_img_dtb_size=$(convert_bytes "${kl_nml_img_dtb_bytes}")
            fi
        fi
    }

    kernel_stats() {
        printf "%b> Defconfig: %s%b\n" "$white" "$KERNEL_DEFCONFIG" "$darkwhite"

        if [ -n "$KERNEL_LOCALVERSION" ]; then
            printf "%b> Localversion: %s%b\n" "$white" "$KERNEL_LOCALVERSION" "$darkwhite"
        fi

        if [ -n "$KERNEL_BUILD_USER" ]; then
            printf "%b> User: %s%b\n" "$white" "$KERNEL_BUILD_USER" "$darkwhite"
        else
            printf "%b> User: %s%b\n" "$white" "$get_username" "$darkwhite"
        fi

        if [ -n "$KERNEL_BUILD_HOST" ]; then
            printf "%b> Host: %s%b\n" "$white" "$KERNEL_BUILD_HOST" "$darkwhite"
        else
            printf "%b> Host: %s%b\n" "$white" "$get_hostname" "$darkwhite"
        fi
    }

    compilation_stats() {

        read_compilation_time() {
            compilation_time_minutes=$((compilation_time / 60))
            compilation_time_seconds=$((compilation_time % 60))

            if [ "$compilation_time_minutes" = 1 ]; then
                compilation_time_minutes_noun=minute
            else
                compilation_time_minutes_noun=minutes
            fi

            if [ "$compilation_time_seconds" = 1 ]; then
                compilation_time_seconds_noun=second
            else
                compilation_time_seconds_noun=seconds
            fi
        }

        read_compilation_details() {
            if [ "$clg" = 1 ]; then
                compilation_details=clang
            elif [ "$out" = 1 ]; then
                compilation_details=gcc-out
            else
                compilation_details=gcc-normal
            fi

            if [ "$USE_CCACHE" = 1 ]; then
                compilation_details="${compilation_details}-ccache"
            fi

            if [ "$dry" = 1 ]; then
                compilation_details="${compilation_details}-dirty"
            fi

            compilation_details="${compilation_details}"
        }

        output_compilation_stats() {
            printf "%b> Compilation took: %d %s and %d %s%b\n" "$white" "$compilation_time_minutes" "$compilation_time_minutes_noun" "$compilation_time_seconds" "$compilation_time_seconds_noun" "$darkwhite"

            printf "%b> Compilation details: %s%b\n" "$white" "$compilation_details" "$darkwhite"
        }

        read_compilation_time
        read_compilation_details
        output_compilation_stats
    }

    images_stats() {

        read_stored_size_of_images() {
            if [ -f "$cache_file_0" ]; then
                grep -Fq "directory=$kl_dir" "$cache_file_0"
                grepexit=$(printf "%d" "$?")

                if [ "$grepexit" = 1 ]; then
                    rm -f "${cache_file_0}"
                fi
            fi

            if [ -f "$cache_file_0" ]; then
                if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
                    if grep -Fq "kernel.out.image.size" "${cache_file_0}"; then
                        kl_out_img_size_stored=$(grep kernel.out.image.size "${cache_file_0}" | cut -d "=" -f2)
                    fi

                    if [ -f "$kl_out_img_dtb" ]; then
                        if grep -Fq "kernel.out.image.dtb.size" "${cache_file_0}"; then
                            kl_out_img_dtb_size_stored=$(grep kernel.out.image.dtb.size "${cache_file_0}" | cut -d "=" -f2)
                        fi
                    fi
                else
                    if grep -Fq "kernel.nml.image.size" "${cache_file_0}"; then
                        kl_nml_img_size_stored=$(grep kernel.nml.image.size "${cache_file_0}" | cut -d "=" -f2)
                    fi

                    if [ -f "$kl_nml_img_dtb" ]; then
                        if grep -Fq "kernel.nml.image.dtb.size" "${cache_file_0}"; then
                            kl_nml_img_dtb_size_stored=$(grep kernel.nml.image.dtb.size "${cache_file_0}" | cut -d "=" -f2)
                        fi
                    fi
                fi
            fi
        }

        output_stats_of_images() {
            if [ -f "$cache_file_0" ]; then
                if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
                    if [ -n "$kl_out_img_size_stored" ]; then
                        printf "%b> Image size: %s (PREVIOUSLY: %s)%b\n" "$white" "$kl_out_img_size" "$kl_out_img_size_stored" "$darkwhite"
                    else
                        printf "%b> Image size: %s%b\n" "$white" "$kl_out_img_size" "$darkwhite"
                    fi

                    if [ -n "$kl_out_img_dtb_size_stored" ]; then
                        printf "%b> Image-dtb size: %s (PREVIOUSLY: %s)%b\n" "$white" "$kl_out_img_dtb_size" "$kl_out_img_dtb_size_stored" "$darkwhite"
                    else
                        if [ -f "$kl_out_img_dtb" ]; then
                            printf "%b> Image-dtb size: %s%b\n" "$white" "$kl_out_img_dtb_size" "$darkwhite"
                        fi
                    fi
                else
                    if [ -n "$kl_nml_img_size_stored" ]; then
                        printf "%b> Image size: %s (PREVIOUSLY: %s)%b\n" "$white" "$kl_nml_img_size" "$kl_nml_img_size_stored" "$darkwhite"
                    else
                        printf "%b> Image size: %s%b\n" "$white" "$kl_nml_img_size" "$darkwhite"
                    fi

                    if [ -n "$kl_nml_img_dtb_size_stored" ]; then
                        printf "%b> Image-dtb size: %s (PREVIOUSLY: %s)%b\n" "$white" "$kl_nml_img_dtb_size" "$kl_nml_img_dtb_size_stored" "$darkwhite"
                    else
                        if [ -f "$kl_nml_img_dtb" ]; then
                            printf "%b> Image-dtb size: %s%b\n" "$white" "$kl_nml_img_dtb_size" "$darkwhite"
                        fi
                    fi
                fi
            else
                if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
                    printf "%b> Image size: %s%b\n" "$white" "$kl_out_img_size" "$darkwhite"

                    if [ -f "$kl_out_img_dtb" ]; then
                        printf "%b> Image-dtb size: %s%b\n" "$white" "$kl_out_img_dtb_size" "$darkwhite"
                    fi
                else
                    printf "%b> Image size: %s%b\n" "$white" "$kl_nml_img_size" "$darkwhite"

                    if [ -f "$kl_nml_img_dtb" ]; then
                        printf "%b> Image-dtb size: %s%b\n" "$white" "$kl_nml_img_dtb_size" "$darkwhite"
                    fi
                fi
            fi

            if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
                printf "%b> Image location: %s%b\n" "$white" "$kl_out_img" "$darkwhite"

                if [ -f "$kl_out_img_dtb" ]; then
                    printf "%b> Image-dtb location: %s%b\n" "$white" "$kl_out_img_dtb" "$darkwhite"
                fi
            else
                printf "%b> Image location: %s%b\n" "$white" "$kl_nml_img" "$darkwhite"

                if [ -f "$kl_nml_img_dtb" ]; then
                    printf "%b> Image-dtb location: %s%b\n" "$white" "$kl_nml_img_dtb" "$darkwhite"
                fi
            fi

            printf "\n"
        }

        store_size_of_images() {
            rm -f "${cache_file_0}"
            touch "${cache_file_0}"

            printf "directory=%s\n" "$kl_dir" >> "${cache_file_0}"

            if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
                printf "kernel.out.image.size=%s\n" "$kl_out_img_size" >> "${cache_file_0}"

                if [ -f "$kl_out_img_dtb" ]; then
                    printf "kernel.out.image.dtb.size=%s\n" "$kl_out_img_dtb_size" >> "${cache_file_0}"
                fi
            else
                printf "kernel.nml.image.size=%s\n" "$kl_nml_img_size" >> "${cache_file_0}"

                if [ -f "$kl_nml_img_dtb" ]; then
                    printf "kernel.nml.image.dtb.size=%s\n" "$kl_nml_img_dtb_size" >> "${cache_file_0}"
                fi
            fi
        }

        read_stored_size_of_images
        output_stats_of_images
        store_size_of_images
    }

    get_bytes_of_images
    convert_bytes_of_images
    kernel_stats
    compilation_stats
    images_stats
}

function zip_builder() {

    copy_image() {
        if [ "$copy_dtb_image" = 1 ]; then
            if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
                if [ -f "$kl_out_img_dtb" ]; then
                    cp "${kl_out_img_dtb}" "${ak_kl_img_dtb}"
                else
                    die_41
                fi
            else
                if [ -f "$kl_nml_img_dtb" ]; then
                    cp "${kl_nml_img_dtb}" "${ak_kl_img_dtb}"
                else
                    die_41
                fi
            fi
        else
            if [ "$clg" = 1 ] || [ "$out" = 1 ]; then
                cp "${kl_out_img}" "${ak_kl_img}"
            else
                cp "${kl_nml_img}" "${ak_kl_img}"
            fi
        fi
    }

    remove_old_zip() {
        rm -f "${ak_dir}"/"${KERNEL_NAME}"*.zip

        if [ "$aggressive_zip_rm" = 1 ]; then
            remove_every_zip "${ak_dir}"
        fi
    }

    filename() {
        if [ -n "$CUSTOM_ZIP_NAME" ]; then
            filename="${CUSTOM_ZIP_NAME}.zip"
        else
            filename="${KERNEL_NAME}"

            if [ -n "$APPEND_VERSION" ]; then
                filename="${filename}-${APPEND_VERSION}"
            fi

            if [ -n "$APPEND_DEVICE" ]; then
                filename="${filename}-${APPEND_DEVICE}"
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
        printf "%bPacking the kernel...%b\n\n" "$cyan" "$darkwhite"

        cd "${ak_dir}" || die_30
        zip -qFSr9 "${filename}" ./* -x .git ./*.zip README.md
    }

    get_bytes_of_zip() {
        zip_bytes=$(wc -c < "${ak_dir}"/"${filename}")
    }

    convert_bytes_of_zip() {
        zip_size=$(convert_bytes "${zip_bytes}")
    }

    get_hash_of_zip() {

        get_md5_of_zip() {
            zip_md5=$(md5sum "${ak_dir}"/"${filename}" | cut -d ' ' -f 1)
        }

        get_sha1_of_zip() {
            zip_sha1=$(sha1sum "${ak_dir}"/"${filename}" | cut -d ' ' -f 1)
        }

        if command_available md5sum; then
            get_md5_of_zip
        fi

        if command_available sha1sum; then
            get_sha1_of_zip
        fi
    }

    zip_stats() {

        read_stored_size_of_zip() {
            if [ -f "$cache_file_1" ]; then
                grep -Fq "directory=$kl_dir" "$cache_file_1"
                grepexit2=$(printf "%d" "$?")

                if [ "$grepexit2" = 1 ]; then
                    rm -f "${cache_file_1}"
                fi
            fi

            if [ -f "$cache_file_1" ]; then
                if grep -Fq "zip.size" "${cache_file_1}"; then
                    zip_size_stored=$(grep zip.size "${cache_file_1}" | cut -d "=" -f2)
                fi
            fi
        }

        output_zip_stats() {
            if [ -n "$zip_md5" ]; then
                printf "%b> Zip MD5: %s%b\n" "$white" "$zip_md5" "$darkwhite"
            fi

            if [ -n "$zip_sha1" ]; then
                printf "%b> Zip SHA-1: %s%b\n" "$white" "$zip_sha1" "$darkwhite"
            fi

            if [ -f "$cache_file_1" ]; then
                if [ -n "$zip_size_stored" ]; then
                    printf "%b> Zip size: %s (PREVIOUSLY: %s)%b\n" "$white" "$zip_size" "$zip_size_stored" "$darkwhite"
                else
                    printf "%b> Zip size: %s%b\n" "$white" "$zip_size" "$darkwhite"
                fi
            else
                printf "%b> Zip size: %s%b\n" "$white" "$zip_size" "$darkwhite"
            fi

            printf "%b> Zip location: %s/%s%b\n\n" "$white" "$ak_dir" "$filename" "$darkwhite"
        }

        store_size_of_zip() {
            rm -f "${cache_file_1}"
            touch "${cache_file_1}"

            printf "directory=%s\n" "$kl_dir" >> "${cache_file_1}"
            printf "zip.size=%s\n" "$zip_size" >> "${cache_file_1}"
        }

        read_stored_size_of_zip
        output_zip_stats
        store_size_of_zip
    }

    copy_image
    remove_old_zip
    filename
    create_zip
    get_bytes_of_zip
    convert_bytes_of_zip
    get_hash_of_zip
    zip_stats
}

variables
automatic_configuration
automatic_variables
environment_check
helpers
traps
die_codes
configuration_checker
package_checker
cloning
choices
pre_compilation_setup
pre_compilation_work
compilation
post_compilation_work
compilation_report
stats

if [ "$ZIP_BUILDER" = 1 ]; then
    zip_builder
fi
