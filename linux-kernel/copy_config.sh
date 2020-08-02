#!/bin/sh
# shellcheck disable=SC2086

: <<'notice'
 * Script information:
 *   Copy .config as defconfig.
 *
 * Usage:
 *   K_DIR: [essential]
 *   Specify the kernel directory.
 *
 *   K_ARCH: [essential]
 *   Specify arch for defconfig.
 *
 *   DEFCONFIG_NAME: [essential]
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

check_config() {
    if [ -z $K_DIR ]; then
        printf "\nK_DIR is empty. Aborting.\n\n"
        exit 1
    fi

    if [ -z $K_ARCH ]; then
        printf "\nK_ARCH is empty. Aborting.\n\n"
        exit 1
    fi

    if [ -z $DEFCONFIG_NAME ]; then
        printf "\nDEFCONFIG_NAME is empty. Aborting.\n\n"
        exit 1
    fi
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

        if [ $cp_rc -eq 0 ]; then
            echo "File was copied successfully."
        fi
    }

    copy_conf_work;
    copy_conf_exec;
}

variables;
check_config;
copy_conf;
