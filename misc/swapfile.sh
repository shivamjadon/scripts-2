#!/bin/sh
# shellcheck disable=SC2086

: <<'notice'
 * Script information:
 *   Create swap file.
 *
 * Usage:
 *   BLOCK_SIZE: [essential] [integer]
 *   Set block size for the swap file. Can be set in bytes and human readable
 *   form (K - KiB, M - MiB, G - GiB, ...), 'man dd' for more info.
 *
 *   BLOCKS_COUNT: [essential] [integer]
 *   Set count of blocks. Can also be set in human readable form
 *   (K - KiB, M - MiB, G - GiB, ...), 'man dd' for more info.
 *
 *   SWAPFILE: [path]
 *   Specify a path to which the swap file shall be written. If a file exists
 *   at the specified path, it will be deleted.
 *
 *   NULL_SOURCE: [path]
 *   Define the source from which dd will take null data to create the file.
 *
 *   SWAPPINESS: [value] [0-100]
 *   Swap intensity.
 *   0 = disabled (Linux 3.5+); avoid OOM condition (Linux < 3.5).
 *   1 = swap only when close to OOM.
 *   5 = swap before memory allocations get slow (recommended for HDD).
 *   10 = relaxed swapping (recommended for SSD).
 *   60 = default.
 *   100 = aggressive swapping.
 *
 *   VERBOSE_DD: [toggle] [1]
 *   0 = 'dd' will be completely silent during file creation.
 *   1 = 'dd' will show output (progress) during file creation.
 *
 * Example configuration:
 *   Block size of 4 KiB and a count of 2 blocks make 8 KiB file (4 KiB * 2).
 *
 *   To create 2 GiB file with block size of 32 KiB, you would use 32768 bytes
 *   (32 KiB) block size and 65536 blocks (32K * 64K = 2G).
 *
 *   To create 2 GiB file with block size of 64 KiB, you would use 65536 bytes
 *   (64 KiB) block size and 32768 blocks (64K * 32K = 2G).
 *
 * Example table:
 *   BLOCK_SIZE * BLOCKS_COUNT = FILE SIZE
 *
 *   512 B * 2097152 = 1 GiB          512 B * 4194304 = 2 GiB
 *   1 KiB * 1048576 = 1 GiB          1 KiB * 2097152 = 2 GiB
 *   2 KiB * 524288 = 1 GiB           2 KiB * 1048576 = 2 GiB
 *   4 KiB * 262144 = 1 GiB           4 KiB * 524288 = 2 GiB
 *   8 KiB * 131072 = 1 GiB           8 KiB * 262144 = 2 GiB
 *   16 KiB * 65536 = 1 GiB           16 KiB * 131072 = 2 GiB
 *   32 KiB * 32768 = 1 GiB           32 KiB * 65536 = 2 GiB
 *   64 KiB * 16384 = 1 GiB           64 KiB * 32768 = 2 GiB
 *   128 KiB * 8192 = 1 GiB           128 KiB * 16384 = 2 GiB
 *   256 KiB * 4096 = 1 GiB           256 KiB * 8192 = 2 GiB
 *   512 KiB * 2048 = 1 GiB           512 KiB * 4096 = 2 GiB
 *   1 MiB * 1024 = 1 GiB             1 MiB * 2048 = 2 GiB
 *   2 MiB * 512 = 1 GiB              2 MiB * 1024 = 2 GiB
 *   4 MiB * 256 = 1 GiB              4 MiB * 512 = 2 GiB
 *   8 MiB * 128 = 1 GiB              8 MiB * 256 = 2 GiB
 *   16 MiB * 64 = 1 GiB              16 MiB * 128 = 2 GiB
 *   32 MiB * 32 = 1 GiB              32 MiB * 64 = 2 GiB
 *   64 MiB * 16 = 1 GiB              64 MiB * 32 = 2 GiB
 *   128 MiB * 8 = 1 GiB              128 MiB * 16 = 2 GiB
 *   256 MiB * 4 = 1 GiB              256 MiB * 8 = 2 GiB
 *   512 MiB * 2 = 1 GiB              512 MiB * 4 = 2 GiB
 *   1 GiB * 1 = 1 GiB                1 GiB * 2 = 2 GiB
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    BLOCK_SIZE=
    BLOCKS_COUNT=

    SWAPFILE=""
    NULL_SOURCE=""
    SWAPPINESS=

    VERBOSE_DD=1
}

check_config() {
    if [ -z $BLOCK_SIZE ]; then
        printf "\nBLOCK_SIZE is empty. Aborting.\n\n"
        exit 1
    fi

    if [ -z $BLOCKS_COUNT ]; then
        printf "\nBLOCKS_COUNT is empty. Aborting.\n\n"
        exit 1
    fi
}

# "$0" - expands to the filename of the script.
# $? - expands to the return code of the last command.
#
# su -c "$0" - execute the shell script as root (effective user id 0).
# exit $? - exit from the current (non-root) shell with return code of 'su'.
#
exec_as_root() {
    euid=$(id -u)

    if [ $euid -ne 0 ]; then
        su -c "$0"
        exit $?
    fi
}

swap() {
    swap_work() {
        swap_work_vars() {
            swap_def_loc="$HOME"/.swapfile

            if [ -z $SWAPFILE ]; then
                SWAPFILE="$swap_def_loc"
            fi

            if [ -z $NULL_SOURCE ]; then
                NULL_SOURCE=/dev/zero
            fi
        }

        swap_work_cmds() {
            if [ -f "$swap_def_loc" ]; then
                swapoff "$swap_def_loc" > /dev/null 2>&1
                rm -fv "$swap_def_loc"
            fi

            if [ -f "$SWAPFILE" ]; then
                swapoff "$SWAPFILE" > /dev/null 2>&1
                rm -fv "$SWAPFILE"
            fi
        }

        swap_work_dd_args() {
            dd_args="if=${NULL_SOURCE}"
            dd_args="${dd_args} of=${SWAPFILE}"
            dd_args="${dd_args} bs=${BLOCK_SIZE}"
            dd_args="${dd_args} count=${BLOCKS_COUNT}"

            if [ $VERBOSE_DD -eq 1 ]; then
                dd_args="${dd_args} status=progress"
            fi
        }

        swap_work_vars;
        swap_work_cmds;
        swap_work_dd_args;
    }

    swap_exec() {
        dd $dd_args

        chmod 600 "$SWAPFILE"
        chown root "$SWAPFILE"

        mkswap "$SWAPFILE"
        swapon "$SWAPFILE"
    }

    swap_parameters() {
        if [ -n "$SWAPPINESS" ]; then
            echo $SWAPPINESS > /proc/sys/vm/swappiness
        fi
    }

    swap_work;
    swap_exec;
    swap_parameters;
}

variables;
check_config;
exec_as_root;
swap;
