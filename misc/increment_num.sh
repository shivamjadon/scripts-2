#!/bin/sh
# shellcheck disable=SC2086

: <<'notice'
 * Script information:
 *   Increment number in filenames by one. Supports whitespace. As always,
 *   do a backup of the files before running the script.
 *
 * Usage:
 *   WORK_DIR: [essential] [path]
 *   Specify the directory in which files with number in their filename exist.
 *
 *   RESULT_DIR: [can be left empty] [path]
 *   Specify a directory to move incremented files to. If the specified
 *   directory does not exist, it will be created. If RESULT_DIR is left empty,
 *   a directory with name "0incrementSH" is created in the same directory
 *   level as WORK_DIR.
 *
 *   INCREMENT_BY: [can be left empty]
 *   Specify by how much to increment. If left empty, default (one) is used.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    WORK_DIR=""
    RESULT_DIR=""
    INCREMENT_BY=
}

check_config() {
    if [ -z $WORK_DIR ]; then
        printf "\nWORK_DIR is empty. Aborting.\n\n"
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
        if [ -z $RESULT_DIR ]; then
            res_dir_loc=$(cd "$WORK_DIR"/.. && printf "%s" "$PWD")
            RESULT_DIR="$res_dir_loc"/0incrementSH
        fi

        if [ -d "$RESULT_DIR" ]; then
            ls "$RESULT_DIR"/* > /dev/null 2>&1
            ls_rc=$(printf "%d" "$?")

            if [ $ls_rc -eq 0 ]; then
                echo
                echo "$RESULT_DIR is not empty, please move out all files!"
                echo
                exit 1
            fi
        else
            mkdir "$RESULT_DIR"
        fi

        if [ -z $INCREMENT_BY ]; then
            INCREMENT_BY=1
        fi
    }

    increment_exec() {
        files="$WORK_DIR/*"

        for file in $files; do
            cur_filename=$(basename "$file")
            cur_loc=$(printf "%s/%s" "${WORK_DIR}" "${cur_filename}")
            new_filename=$(increment_num_in_str "$cur_filename")
            new_loc=$(printf "%s/%s" "${RESULT_DIR}" "${new_filename}")

            mv -v "$cur_loc" "$new_loc"
        done
    }

    increment_work;
    increment_exec;
}

variables;
check_config;
helpers;
increment;