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

helpers() {
    increment_num_str() {
        str="$1"

        for num in $(printf "%s" "${str}" | grep -Eo '[0-9]+'); do
            old_num=$(printf "%d" "${num}")
            new_num=$((num + INCREMENT_BY))
        done

        new_str=$(printf "%s" "${str}" | sed "s/$old_num/$new_num/")

        printf "%s" "${new_str}"
    }

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

probe_vars() {
    if [ -z $WORK_DIR ]; then
        script_death "" "" "" "WORK_DIR is empty" ""
    fi
}

increment() {
    increment_work() {
        increment_work_vars() {
            tmp_dir_loc=$(cd "$WORK_DIR"/.. && printf "%s" "$PWD")
            tmp_dir="$tmp_dir_loc"/TMPincrement
            
            if [ -z $INCREMENT_BY ]; then
                INCREMENT_BY=1
            fi
        }

        increment_work_cmds() {
            if [ -d "$tmp_dir" ]; then
                rm -rf "$tmp_dir"
            fi

            mkdir "$tmp_dir"
        }

        increment_work_vars;
        increment_work_cmds;
    }

    increment_exec() {
        files="$WORK_DIR/*"
        files_tmp="$tmp_dir/*"

        for file in $files; do
            cur_filename=$(basename "$file")
            cur_loc=$(printf "%s/%s" "${WORK_DIR}" "${cur_filename}")
            new_filename=$(increment_num_str "$cur_filename")
            new_loc=$(printf "%s/%s" "${tmp_dir}" "${new_filename}")

            mv -v "$cur_loc" "$new_loc"
        done

        for file in $files_tmp; do
            cur_filename=$(basename "$file")
            cur_loc=$(printf "%s/%s" "${tmp_dir}" "${cur_filename}")
            new_loc=$(printf "%s/%s" "${WORK_DIR}" "${cur_filename}")

            mv -v "$cur_loc" "$new_loc"
        done
    }

    increment_cleanup() {
        rm -rf "$tmp_dir"
    }

    increment_work;
    increment_exec;
    increment_cleanup;
}

variables;
helpers;
probe_vars;
increment;
