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
}

function automatic_variables() {

    import_variables_0() {
        SCRIPT_VARIABLES
    }

    colors() {
        red='\033[1;31m'
        white='\033[1;37m'
        darkwhite='\033[0;37m'
    }

    location_shortcuts() {
        kl_dir="$HOME"/${KERNEL_DIR}
        conf_file="$HOME"/${KERNEL_DIR}/.config
        conf_loc="$HOME"/${KERNEL_DIR}/arch/arm64/configs/${NAME_FOR_DEFCONFIG}
    }

    import_variables_0
    colors
    location_shortcuts
}

function env_checks() {

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

function die_codes() {

    die_10() {
        printf "\n%bYou changed one or more variables' names.%b\n\n" "$red" "$darkwhite"
        exit 10
    }

    die_11() {
        printf "\n%bYou did not define all variables.%b\n\n" "$red" "$darkwhite"
        exit 11
    }

    die_20() {
        printf "\n%bUnexpected path issue.%b\n\n" "$red" "$darkwhite"
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

    missing_variables() {
        if [ ! -d "$KERNEL_DIR" ]; then
            printf "\n%bThe defined kernel directory location is inexistent.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi

        if [ ! -f "$conf_file" ]; then
            printf "\n%bNo config file is found in the defined kernel directory.%b\n\n" "$red" "$darkwhite"
            exit 1
        fi
    }

    check_for_slash() {
        local kd_first_char
        local kd_last_char
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
    missing_variables
    check_for_slash
}

function copy_config() {

    do_cd() {
        cd "${kl_dir}" || die_20
    }

    do_cp() {
        cp .config arch/arm64/configs/"${NAME_FOR_DEFCONFIG}"
    }

    do_cd
    do_cp
}

function stats() {

    config_stats() {
        printf "\n\n%b> Location: %s%b\n\n" "$white" "$conf_loc" "$darkwhite"
    }

    config_stats
}

variables
automatic_variables
env_checks
die_codes
configuration_checker
copy_config
stats
