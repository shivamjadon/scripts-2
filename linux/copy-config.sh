#!/bin/bash

: <<'notice'
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

function variables() {

    SCRIPT_VARIABLES() {
        KERNEL_DIR=
        NAME_FOR_DEFCONFIG=
    }

    SCRIPT_VARIABLES
}

function additional_variables() {
    red='\033[1;31m'
    white='\033[1;37m'
    darkwhite='\033[0;37m'
    kl_dir="$HOME"/${KERNEL_DIR}
}

function env_checks() {

    bash_check() {
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

function die_codes() {

    die_10() {
        printf "\n%bYou changed one or more variables' names.\nExit code: 10.%b\n\n" "$red" "$darkwhite"
        exit 10
    }

    die_11() {
        printf "\n%bYou did not define all variables.\nExit code: 11.%b\n\n" "$red" "$darkwhite"
        exit 11
    }

    die_20() {
        printf "\n%bUnexpected path issue.\nExit code: 20.%b\n\n" "$red" "$darkwhite"
        exit 20
    }
}

function configuration_checker() {

    changed_variables() {
        if [ ! -v KERNEL_DIR ] || [ ! -v NAME_FOR_DEFCONFIG ]; then
            die_10
        fi
    }

    undefined_variables() {
        if [ -z "$KERNEL_DIR" ] || [ -z "$NAME_FOR_DEFCONFIG" ]; then
            die_11
        fi
    }

    check_for_slash() {
        kd_first_char=$(printf "%s" "$KERNEL_DIR" | cut -c -1)
        kd_last_char=$(printf "%s" "$KERNEL_DIR" | sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' | cut -c -1)

        if [ "$kd_first_char" = "/" ]; then
            printf "\n%bRemove the first slash (/) in KERNEL_DIR variable.%b\n\n" "$red" "$darkwhite"
            exit 1
        elif [ "$kd_last_char" = "/" ]; then
            printf "\n%bRemove the last slash (/) in KERNEL_DIR variable.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi
    }

    changed_variables
    undefined_variables
    check_for_slash
}

function copy_config() {
    cd "${kl_dir}" || die_20
    cp .config arch/arm64/configs/${NAME_FOR_DEFCONFIG}
}

function stats() {
    printf "\n%bDone!%b\n\n" "$white" "$darkwhite"
    printf "%b%s location:\n%s/arch/arm64/configs/%s%b\n\n" "$white" "$NAME_FOR_DEFCONFIG" "$kl_dir" "$NAME_FOR_DEFCONFIG" "$darkwhite"
}

variables
additional_variables
env_checks
die_codes
configuration_checker
copy_config
stats
