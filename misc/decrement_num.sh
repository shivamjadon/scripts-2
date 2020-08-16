#!/bin/sh
# shellcheck disable=SC2086

: <<'notice'
 * Script information:
 *   Decrement number in filenames. Supports whitespace. As always, do a backup
 *   of the files before running the script.
 *
 * Usage:
 *   WORK_DIR: [essential] [path]
 *   Specify the directory in which files with number in their filename exist.
 *
 *   DECREMENT_BY: [value] [X]
 *   Specify by how much to decrement. If left empty, default (1) is used.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    WORK_DIR=""
    DECREMENT_BY=
}

colors() {
    default_clr="\033[0m"
    red_clr="\033[1;31m"
}

check_config() {
    if [ -z $WORK_DIR ]; then
        printf "%b" "${red_clr}"
        echo "WORK_DIR is empty. Aborting."
        printf "%b" "${default_clr}"
        exit 1
    fi
}

helpers() {
    decrement_num_in_str() {
        str="$1"

        for num in $(printf "%s" "${str}" | grep -Eo '[0-9]+'); do
            old_num=$(printf "%d" "${num}")
            new_num=$((num - DECREMENT_BY))
        done

        new_str=$(printf "%s" "${str}" | sed "s/$old_num/$new_num/")

        printf "%s" "${new_str}"
    }
}

decrement() {
    decrement_work() {
        decrement_work_vars() {
            tmp_dir_loc=$(cd "$WORK_DIR"/.. && printf "%s" "$PWD")
            TMP_DIR="$tmp_dir_loc"/TMPdecrement

            if [ -z $DECREMENT_BY ]; then
                DECREMENT_BY=1
            fi
        }

        decrement_work_cmds() {
            if [ -d "$TMP_DIR" ]; then
                rm -rf "$TMP_DIR"
            fi

            mkdir "$TMP_DIR"
        }

        decrement_work_vars;
        decrement_work_cmds;
    }

    decrement_exec() {
        files="$WORK_DIR/*"
        files_tmp="$TMP_DIR/*"

        for file in $files; do
            cur_filename=$(basename "$file")
            cur_loc=$(printf "%s/%s" "${WORK_DIR}" "${cur_filename}")
            new_filename=$(decrement_num_in_str "$cur_filename")
            new_loc=$(printf "%s/%s" "${TMP_DIR}" "${new_filename}")

            mv -v "$cur_loc" "$new_loc"
        done

        for file in $files_tmp; do
            cur_filename=$(basename "$file")
            cur_loc=$(printf "%s/%s" "${TMP_DIR}" "${cur_filename}")
            new_loc=$(printf "%s/%s" "${WORK_DIR}" "${cur_filename}")

            mv -v "$cur_loc" "$new_loc"
        done
    }

    decrement_cleanup() {
        rm -rf "$TMP_DIR"
    }

    decrement_work;
    decrement_exec;
    decrement_cleanup;
}

variables;
colors;
check_config;
helpers;
decrement;
