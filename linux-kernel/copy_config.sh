#!/bin/sh
# shellcheck disable=SC2086

: <<'notice'
 * Script information:
 *   Copy .config as defconfig.
 *
 * Usage:
 *   K_DIR: [essential] [path]
 *   Specify the kernel directory.
 *
 *   K_ARCH: [essential] [string]
 *   Specify arch for defconfig.
 *
 *   DEFCONFIG_NAME: [essential] [string]
 *   Specify name for defconfig.
 *
 *   VENDOR_DEFCONFIG: [toggle] [0]
 *   0 = .config will be copied to arch/<arch>/configs
 *   1 = .config will be copied to arch/<arch>/configs/vendor
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    K_DIR=""
    K_ARCH=
    DEFCONFIG_NAME=

    VENDOR_DEFCONFIG=0
}

colors() {
    default_clr="\033[0m"
    red_clr="\033[1;31m"
    white_clr="\033[1;37m"
}

check_config() {
    if [ -z $K_DIR ]; then
        printf "%b" "${red_clr}"
        echo "K_DIR is empty. Aborting."
        printf "%b" "${default_clr}"
        exit 1
    fi

    if [ -z $K_ARCH ]; then
        printf "%b" "${red_clr}"
        echo "K_ARCH is empty. Aborting."
        printf "%b" "${default_clr}"
        exit 1
    fi

    if [ -z $DEFCONFIG_NAME ]; then
        printf "%b" "${red_clr}"
        echo "DEFCONFIG_NAME is empty. Aborting."
        printf "%b" "${default_clr}"
        exit 1
    fi
}

helpers() {
    script_death() {
        hlps_cmd=$(printf "%s" "$1")
        hlps_cmd_rc=$(printf "%d" "$2")
        hlps_line=$(printf "%d" "$3")
        hlps_info=$(printf "%s" "$4")
        hlps_exec_func=$(printf "%s" "$5")

        echo

        printf "%b" "\033[1;31m"
        echo "Script failed!"
        printf "%b" "\033[1;37m"

        if [ -n "$hlps_cmd" ]; then
            printf "Command: %s" "${hlps_cmd}"
            echo
        fi

        if [ -n "$hlps_cmd_rc" ] && [ $hlps_cmd_rc -ne 0 ]; then
            printf "Exit code: %d" "${hlps_cmd_rc}"
            echo
        fi

        if [ -n "$hlps_line" ] && [ $hlps_line -ne 0 ]; then
            printf "Line number: %d" "${hlps_line}"
            echo
        fi

        if [ -n "$hlps_info" ]; then
            printf "Additional info: %s" "${hlps_info}"
            echo
        fi

        printf "%b" "\033[0m"

        echo

        if [ -n "$hlps_exec_func" ]; then
            ${hlps_exec_func};
        fi

        if [ -n "$hlps_cmd_rc" ] && [ $hlps_cmd_rc -ne 0 ]; then
            exit $hlps_cmd_rc
        else
            exit 1
        fi
    }
}

copy_conf() {
    copy_conf_work() {
        cp_conf_loc="$K_DIR"/.config
        cp_dest_loc="$K_DIR"/arch/$K_ARCH/configs/$DEFCONFIG_NAME

        if [ $VENDOR_DEFCONFIG -eq 1 ]; then
            cp_dest_loc="$K_DIR"/arch/$K_ARCH/configs/vendor/$DEFCONFIG_NAME
        fi
    }

    copy_conf_exec() {
        cp "$cp_conf_loc" "$cp_dest_loc"
        cp_rc=$(printf "%d" "$?")

        if [ $cp_rc -ne 0 ]; then
            script_death "cp" "${cp_rc}" "" "File copy failed" ""
        fi
    }

    copy_conf_work;
    copy_conf_exec;
}

variables;
colors;
check_config;
helpers;
copy_conf;
