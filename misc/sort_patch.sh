#!/bin/sh
# shellcheck disable=SC2086
# shellcheck disable=SC2164

: <<'notice'
 * Script information:
 *   Feed me a file with links to commits and I will sort them by date!
 *
 * Usage:
 *   FILE: [essential] [path]
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
 *   0 = The final file will only have the commit strings.
 *   1 = The final file will have respective link appended to the commit
 *       strings.
 *
 *   STRIP_SCRIPT_STRINGS: [toggle] [0]
 *   0 = The final file will contain additional hardcoded info: line numbers,
 *       date, and file timestamp.
 *   1 = Script strings (line numbers, date, and file timestamp) will not be
 *       appended to the final file.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    FILE=""
    RESULT_FILE=""
    SORT_BY_NEWEST=0
    PRESERVE_COMMIT_LINK=0
    STRIP_SCRIPT_STRINGS=0
}

helpers() {
    cmd_available() {
        hlps_cmd=$(printf "%s" "$1")

        if command -v "$hlps_cmd" > /dev/null 2>&1; then
            return 0
        else
            return 127
        fi
    }

    script_death() {
        hlps_cmd=$(printf "%s" "$1")
        hlps_cmd_rc=$(printf "%d" "$2")
        hlps_line=$(printf "%d" "$3")
        hlps_info=$(printf "%s" "$4")
        hlps_exec_func=$(printf "%s" "$5")
        hlps_exec_func0=$(printf "%s" "$6")

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

        if [ -n "$hlps_exec_func" ]; then
            ${hlps_exec_func};
        fi

        if [ -n "$hlps_exec_func0" ]; then
            ${hlps_exec_func0};
        fi

        echo

        if [ -n "$hlps_cmd_rc" ] && [ $hlps_cmd_rc -ne 0 ]; then
            exit $hlps_cmd_rc
        else
            exit 1
        fi
    }

    tmp_rw() {
        hlps_main_tmp=$(printf "%s" "$1")
        hlps_sec_tmp=$(printf "%s" "$2")
        hlps_op_code=$(printf "%s" "$3")

        if [ $hlps_op_code -eq 1 ]; then
            # Secondary tmp *might* be used again, prepare it
            rm -f "$hlps_main_tmp"
            touch "$hlps_main_tmp"
            cat "$hlps_sec_tmp" > "$hlps_main_tmp"
            rm -f "$hlps_sec_tmp"
            touch "$hlps_sec_tmp"
        fi
    }
}

probe_vars() {
    if [ -z $FILE ]; then
        script_death "" "" "" "FILE is empty" "" ""
    fi
}

sort_patch() {
    sort_patch_work() {
        sort_patch_work_vars() {
            work_file_dir=$(printf "%s" "${FILE%/*}")
            tmp_dir="$work_file_dir"/.0TMPdir
            main_tmp="$work_file_dir"/.0TMPfile
            sec_tmp="$work_file_dir"/.0TMPfile2
            rslt_file_def_loc="$work_file_dir"/0sort_patch.log

            if [ -z "$RESULT_FILE" ]; then
                RESULT_FILE="$rslt_file_def_loc"
            fi
        }

        sort_patch_work_cmds() {
            if [ -f "$rslt_file_def_loc" ]; then
                rm -fv "$rslt_file_def_loc"
            fi

            if [ -f "$RESULT_FILE" ]; then
                rm -fv "$RESULT_FILE"
            fi

            if cmd_available curl; then
                dw_tool="curl"
                dw_tool_args="-O"
            elif cmd_available wget; then
                dw_tool="wget"
                dw_tool_args="-P ${tmp_dir}"
            else
                script_death "" "127" "" "No file download tool available" "" ""
            fi

            if [ -d "$tmp_dir" ]; then
                rm -rf "$tmp_dir"
            fi

            if [ -f "$main_tmp" ]; then
                rm -f "$main_tmp"
            fi

            if [ -f "$sec_tmp" ]; then
                rm -f "$sec_tmp"
            fi

            mkdir "$tmp_dir"
            touch "$main_tmp"
            touch "$sec_tmp"
        }

        sort_patch_work_dw_tool() {
            if [ $dw_tool = curl ]; then
                cd "$tmp_dir"
                cd_rc=$(printf "%d" "$?")

                if [ $cd_rc -ne 0 ]; then
                    script_death "cd" "${cd_rc}" "$LINENO" "" \
                                 "sort_patch_cleanup" ""
                fi
            fi
        }

        sort_patch_work_vars;
        sort_patch_work_cmds;
        sort_patch_work_dw_tool;
    }

    sort_patch_exec() {
        sort_patch_exec_dw() {
            while IFS= read -r line || [ -n "$line" ]; do
                patch_url=${line}.patch

                $dw_tool ${dw_tool_args} $patch_url
            done < "$FILE"
        }

        sort_patch_exec_rw() {
            patches="$tmp_dir/*"

            for patch in $patches; do
                commit_line=$(sed '1q;d' $patch)
                commit_str=$(printf "%s" "${commit_line}" | cut -d ' ' -f2)
                date_line=$(sed '3q;d' $patch)
                date_str=$(printf "%s" "${date_line}" | cut -d ' ' -f3,4,5,6)

                if [ $PRESERVE_COMMIT_LINK -eq 1 ]; then
                    commit_link=$(grep -F $commit_str "$FILE")
                    commit_link_str=$(printf "%s" "${commit_link}" | \
                                      sed "s/${commit_str}//g")
                    commit_str=$(printf "%s%s" "${commit_link_str}" \
                                               "${commit_str}")
                fi

                {
                    printf "%s" "${commit_str}"
                    printf " "
                    printf "%s" "${date_str}"
                    printf "\n"
                } >> "$main_tmp"
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
                "$main_tmp" > "$sec_tmp"

            tmp_rw "$main_tmp" "$sec_tmp" "1"

            if [ $SORT_BY_NEWEST -eq 1 ]; then
                awk '{a[i++]=$0;} END {for (j=i-1; j>=0;) print a[j--];}' \
                    "$main_tmp" > "$sec_tmp"
                tmp_rw "$main_tmp" "$sec_tmp" "1"
            fi

            if [ $STRIP_SCRIPT_STRINGS -eq 0 ]; then
                while IFS= read -r line || [ -n "$line" ]; do
                    num=$((1 + cnt))
                    cnt=$num

                    {
                        printf "%s\n" "$line" | sed "s/^/$num - /"
                    } >> "$sec_tmp"
                done < "$main_tmp"

                tmp_rw "$main_tmp" "$sec_tmp" "1"
            fi

            if [ $STRIP_SCRIPT_STRINGS -eq 1 ]; then
                cut -d ' ' -f1 "$main_tmp" > "$sec_tmp"
                tmp_rw "$main_tmp" "$sec_tmp" "1"
            fi

            touch "$RESULT_FILE"
            cat "$main_tmp" > "$RESULT_FILE"

            if [ $STRIP_SCRIPT_STRINGS -eq 0 ]; then
                date=$(date "+%b %-e, %T %:z %Y")

                {
                    printf "\n"
                    printf "This file was generated by sort_patch on %s" \
                           "${date}"
                    printf "\n"
                } >> "$RESULT_FILE"
            fi
        }

        sort_patch_exec_dw;
        sort_patch_exec_rw;
        sort_patch_exec_sort;
    }

    sort_patch_cleanup() {
        rm -rf "$tmp_dir"
        rm -f "$main_tmp"
        rm -f "$sec_tmp"
    }

    sort_patch_work;
    sort_patch_exec;
    sort_patch_cleanup;
}

variables;
helpers;
probe_vars;
sort_patch;
