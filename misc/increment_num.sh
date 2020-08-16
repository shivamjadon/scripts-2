#!/bin/sh
# shellcheck disable=SC2086

: <<'notice'
 * Script information:
 *   Increment number in filenames. Supports whitespace. As always, do a backup
 *   of the files before running the script.
 *
 * Usage:
 *   WORK_DIR: [essential] [path]
 *   Specify the directory in which files with number in their filename exist.
 *
 *   INCREMENT_BY: [value] [X]
 *   Specify by how much to increment. If left empty, default (1) is used.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    WORK_DIR=""
    INCREMENT_BY=
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
    increment_num_in_str() {
        str="$1"

        for num in $(printf "%s" "${str}" | grep -Eo '[0-9]+'); do
            old_num=$(printf "%d" "${num}")
            new_num=$((num + INCREMENT_BY))
        done

        new_str=$(printf "%s" "${str}" | sed "s/$old_num/$new_num/")

        printf "%s" "${new_str}"
    }
}

increment() {
    increment_work() {
        increment_work_vars() {
            tmp_dir_loc=$(cd "$WORK_DIR"/.. && printf "%s" "$PWD")
            TMP_DIR="$tmp_dir_loc"/TMPincrement
            
            if [ -z $INCREMENT_BY ]; then
                INCREMENT_BY=1
            fi
        }

        increment_work_cmds() {
            if [ -d "$TMP_DIR" ]; then
                rm -rf "$TMP_DIR"
            fi

            mkdir "$TMP_DIR"
        }

        increment_work_vars;
        increment_work_cmds;
    }

    increment_exec() {
        files="$WORK_DIR/*"
        files_tmp="$TMP_DIR/*"

        for file in $files; do
            cur_filename=$(basename "$file")
            cur_loc=$(printf "%s/%s" "${WORK_DIR}" "${cur_filename}")
            new_filename=$(increment_num_in_str "$cur_filename")
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

    increment_cleanup() {
        rm -rf "$TMP_DIR"
    }

    increment_work;
    increment_exec;
    increment_cleanup;
}

variables;
colors;
check_config;
helpers;
increment;
