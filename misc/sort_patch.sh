#!/bin/sh
# shellcheck disable=SC2086
# shellcheck disable=SC2164

: <<'notice'
 * Script information:
 *   Feed me a file with links to commits and I will sort them by date!
 *
 * Usage:
 *   WORK_FILE: [essential] [path]
 *   Specify the file with links to commits.
 *
 *   RESULT_FILE: [path]
 *   Specify a file to which the sorted commits will be written. If the location
 *   is already a valid file, it will be deleted.
 *
 *   SORT_BY_NEWEST: [toggle] [0]
 *   0 = Sort with numbers starting from 1 to X, top to bottom, oldest to
 *       newest.
 *   1 = Sort with numbers starting from 1 to X, top to bottom, newest to
 *       oldest.
 *
 *   PRESERVE_COMMIT_LINK: [toggle] [0]
 *   0 = The final file will only have the commit string.
 *   1 = The final file will have respective link appended to commit string.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    WORK_FILE=""
    RESULT_FILE=""
    SORT_BY_NEWEST=0
    PRESERVE_COMMIT_LINK=0
}

colors() {
    default_clr="\033[0m"
    red_clr="\033[1;31m"
    white_clr="\033[1;37m"
}

check_config() {
    if [ -z $WORK_FILE ]; then
        printf "%b" "${red_clr}"
        echo "WORK_FILE is empty. Aborting."
        printf "%b" "${default_clr}"
        exit 1
    fi
}

helpers() {
    command_available() {
        hlps_str=$(printf "%s" "$1")

        if command -v "$hlps_str" > /dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    }

    script_death() {
        hlps_rc=$(printf "%d" "$1")
        hlps_str=$(printf "%s" "$2")
        hlps_line=$(printf "%s" "$3")
        hlps_exec_func=$(printf "%s" "$4")

        printf "%b\n" "${red_clr}"
        echo "Script failed! More info:"
        printf "%b" "${white_clr}"
        printf "Command: %s" "${hlps_str}"
        echo
        printf "Exit code: %d" "${hlps_rc}"
        echo
        printf "Line number: %d" "${hlps_line}"
        echo
        printf "%b\n" "${default_clr}"

        ${hlps_exec_func};

        exit $hlps_rc
    }
}

sort_patch() {
    sort_patch_work() {
        sort_patch_work_vars() {
            work_file_dir=$(printf "%s" "${WORK_FILE%/*}")
            tmp_dir="$work_file_dir"/.0TMPdir
            tmp_file="$work_file_dir"/.0TMPfile
            tmp_file2="$work_file_dir"/.0TMPfile2
            result_file_def_loc="$work_file_dir"/0sort_patch.log

            if [ -z "$RESULT_FILE" ]; then
                RESULT_FILE="$result_file_def_loc"
            fi
        }

        sort_patch_work_cmds() {
            if [ -f "$result_file_def_loc" ]; then
                rm -fv "$result_file_def_loc"
            fi

            if [ -f "$RESULT_FILE" ]; then
                rm -fv "$RESULT_FILE"
            fi

            if command_available curl; then
                dw_tool="curl"
                dw_tool_args="-O"
            elif command_available wget; then
                dw_tool="wget"
                dw_tool_args="-P ${tmp_dir}"
            else
                printf "%b" "${red_clr}"
                echo "No file download tool available."
                printf "%b" "${default_clr}"
                exit 1
            fi

            if [ -d "$tmp_dir" ]; then
                rm -rf "$tmp_dir"
            fi

            if [ -f "$tmp_file" ]; then
                rm -f "$tmp_file"
            fi

            if [ -f "$tmp_file2" ]; then
                rm -f "$tmp_file2"
            fi

            mkdir "$tmp_dir"
            touch "$tmp_file"
            touch "$tmp_file2"
        }

        sort_patch_work_dw_tool() {
            if [ $dw_tool = curl ]; then
                cd "$tmp_dir"
                cd_rc=$(printf "%d" "$?")

                if [ $cd_rc -ne 0 ]; then
                    script_death "${cd_rc}" "cd" "$LINENO" "sort_cleanup"
                fi
            fi
        }

        sort_patch_work_vars;
        sort_patch_work_cmds;
        sort_patch_work_dw_tool;
    }

    sort_patch_exec() {
        sort_patch_exec_download() {
            while IFS= read -r line || [ -n "$line" ]; do
                patch_url=${line}.patch

                $dw_tool ${dw_tool_args} $patch_url
            done < "$WORK_FILE"
        }

        sort_patch_exec_rw() {
            patches="$tmp_dir/*"

            for patch in $patches; do
                commit_line=$(sed '1q;d' $patch)
                commit_str=$(printf "%s" "${commit_line}" | cut -d ' ' -f2)
                date_line=$(sed '3q;d' $patch)
                date_str=$(printf "%s" "${date_line}" | cut -d ' ' -f3,4,5,6)

                if [ $PRESERVE_COMMIT_LINK -eq 1 ]; then
                    c_link=$(grep -F $commit_str "$WORK_FILE")
                    cl_str=$(printf "%s" "${c_link}" | sed "s/${commit_str}//g")
                    c_str=$commit_str
                    commit_str=$(printf "%s%s" "${cl_str}" "${c_str}")
                fi

                {
                    printf "%s" "${commit_str}"
                    printf " "
                    printf "%s" "${date_str}"
                    printf "\n"
                } >> "$tmp_file"
            done
        }

        sort_patch_exec_sort() {
            sort -t " " \
                -k4.1,4.4 \
                -k3.1,3.3M \
                -k2.1n \
                -k5.1,5.2 \
                -k5.4,5.5 \
                -k5.7,5.8 \
                "$tmp_file" > "$tmp_file2"

            rm -f "$tmp_file"
            touch "$tmp_file"
            cat "$tmp_file2" > "$tmp_file"
            rm -f "$tmp_file2"
            touch "$tmp_file2"

            if [ $SORT_BY_NEWEST -eq 1 ]; then
                awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' \
                    "$tmp_file" > "$tmp_file2"
                rm -f "$tmp_file"
                touch "$tmp_file"
                cat "$tmp_file2" > "$tmp_file"
                rm -f "$tmp_file2"
                touch "$tmp_file2"
            fi

            while IFS= read -r line || [ -n "$line" ]; do
                num_str=$((1 + cnt))
                cnt=$num_str

                {
                    printf "%s\n" "$line" | sed "s/^/$num_str - /"
                } >> "$tmp_file2"
            done < "$tmp_file"

            rm -f "$tmp_file"
            touch "$tmp_file"
            cat "$tmp_file2" > "$tmp_file"

            touch "$RESULT_FILE"
            cat "$tmp_file" > "$RESULT_FILE"

            date=$(date)

            {
                printf "\n"
                printf "This file was generated by sort_patch on %s" "${date}"
                printf "\n"
            } >> "$RESULT_FILE"
        }

        sort_patch_exec_download;
        sort_patch_exec_rw;
        sort_patch_exec_sort;
    }

    sort_patch_cleanup() {
        rm -rf "$tmp_dir"
        rm -f "$tmp_file"
        rm -f "$tmp_file2"
    }

    sort_patch_work;
    sort_patch_exec;
    sort_patch_cleanup;
}

variables;
colors;
check_config;
helpers;
sort_patch;
