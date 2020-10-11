#!/bin/sh
# shellcheck disable=SC2086
# shellcheck disable=SC2164

: <<'notice'
 *
 * Script information:
 *   Advanced universal script for kernel building.
 *
 * Usage:
 *   KL_DIR: [essential] [path]
 *   Specify the kernel directory.
 *
 *   KL_DCONF: [essential] [string]
 *   Specify the defconfig to use.
 *
 *   KL_ARCH: [essential] [string]
 *   Specify the architecture to build for.
 *
 *   TC_DIR: [path]
 *   Specify directory that contains a cross compiler. If left empty, only the
 *   host compiler will be used.
 *
 *   CCACHE: [toggle] [0]
 *   0 = 'ccache' will not be used.
 *   1 = 'ccache' will be used.
 *
 *   CORES: [value] [X]
 *   Specify how many CPU cores to use. If left empty, all cores will be used.
 *
 *   LOCALVERSION: [string]
 *   Append a string to the kernel release. For example, a string such as "-wow"
 *   will set the kernel release version from "5.8.7" to "5.8.7-wow", assuming
 *   no external modifications take place.
 *
 *   CLEAN_BUILD: [toggle] [0]
 *   0 = the script will not perform any kind of build cleaning.
 *   1 = the script will delete output files from previous build and/or run
 *       'make clean && make mrproper' where appropriate.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    KL_DIR=""
    KL_DCONF=
    KL_ARCH=

    TC_DIR=""
    CCACHE=0
    CORES=
    LOCALVERSION=
    CLEAN_BUILD=0
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

    text_clr() {
        hlps_clr=$(printf "%s" "$1")

        if [ $hlps_clr = def ]; then
            printf "%b" "\033[0m"
        elif [ $hlps_clr = black ]; then
            printf "%b" "\033[1;30m"
        elif [ $hlps_clr = red ]; then
            printf "%b" "\033[1;31m"
        elif [ $hlps_clr = green ]; then
            printf "%b" "\033[1;32m"
        elif [ $hlps_clr = yellow ]; then
            printf "%b" "\033[1;33m"
        elif [ $hlps_clr = blue ]; then
            printf "%b" "\033[1;34m"
        elif [ $hlps_clr = purple ]; then
            printf "%b" "\033[1;35m"
        elif [ $hlps_clr = cyan ]; then
            printf "%b" "\033[1;36m"
        elif [ $hlps_clr = white ]; then
            printf "%b" "\033[1;37m"
        fi
    }
}

probe_vars() {
    if [ -z $KL_DIR ]; then
        script_death "" "" "" "KL_DIR is empty" "" ""
    fi

    if [ -z $KL_DCONF ]; then
        script_death "" "" "" "KL_DCONF is empty" "" ""
    fi

    if [ -z $KL_ARCH ]; then
        script_death "" "" "" "KL_ARCH is empty" "" ""
    fi
}

env_check() {
    env_check_root() {
        euid=$(id -u)

        if [ $euid -eq 0 ]; then
            script_death "" "" "" "EUID is 0 (root)" "" ""
        fi
    }

    env_check_root;
}

pkg_check() {
    pkg_check_coreutils() {
        if ! cmd_available nproc; then
            script_death "nproc" "127" "" "'coreutils' is not installed" "" ""
        fi
    }

    pkg_check_ccache() {
        if [ $CCACHE -eq 1 ]; then
            if ! cmd_available ccache; then
                script_death "ccache" "127" "" "'ccache' is not installed" "" ""
            fi
        fi
    }

    pkg_check_coreutils;
    pkg_check_ccache;
}

build_kernel() {
    build_kernel_work() {
        build_kernel_work_vars() {
            kl_out_dir="${KL_DIR}"out
            kl_conf="$KL_DIR"/arch/$KL_ARCH/configs/$KL_DCONF
            kl_vendor_conf="$KL_DIR"/arch/$KL_ARCH/configs/vendor/$KL_DCONF
            kl_conf_make=$KL_DCONF
            kl_vendor_conf_make=vendor/$KL_DCONF
            kl_conf_obj="$KL_DIR"/scripts/kconfig/conf.o
            cpu_avl_cores=$(nproc --all)
            gcc_loc=$(command -v gcc)
            ccache_loc=$(command -v ccache)

            if [ -n "$CORES" ]; then
                cpu_avl_cores=${CORES}
            fi
        }

        build_kernel_work_cmds() {
            if [ ! -f "$kl_conf" ]; then
                if [ -f "$kl_vendor_conf" ]; then
                    kl_conf_make="$kl_vendor_conf_make"
                else
                    script_death "" "" "" "Cannot find ${KL_DCONF}" "" ""
                fi
            fi

            if [ -n "$TC_DIR" ]; then
                cd "$TC_DIR"/lib/gcc
                cd_rc=$(printf "%d" "$?")

                if [ $cd_rc -ne 0 ]; then
                    script_death "cd" "${cd_rc}" "$LINENO" \
                                 "Cannot determine toolchain prefix" "" ""
                fi

                cd -- *
                cd_rc=$(printf "%d" "$?")

                if [ $cd_rc -ne 0 ]; then
                    script_death "cd" "${cd_rc}" "$LINENO" \
                                 "Cannot determine toolchain prefix" "" ""
                fi

                tc_prefix=$(basename "$PWD")-
            fi
        }

        build_kernel_work_env() {
            KBUILD_OUTPUT="$kl_out_dir"
            KBUILD_BUILD_USER=$(id -un)
            KBUILD_BUILD_HOST=$(uname -n)
            ARCH=$KL_ARCH
            SUBARCH=$KL_ARCH

            if [ -n "$TC_DIR" ]; then
                CROSS_COMPILE="${TC_DIR}/bin/${tc_prefix}"

                if [ $CCACHE -eq 1 ]; then
                    CROSS_COMPILE="${ccache_loc} ${CROSS_COMPILE}"
                fi

                export CROSS_COMPILE
            fi

            if [ -n "$LOCALVERSION" ]; then
                export LOCALVERSION=$LOCALVERSION
            fi

            export KBUILD_OUTPUT
            export KBUILD_BUILD_USER
            export KBUILD_BUILD_HOST
            export ARCH
            export SUBARCH
        }

        build_kernel_work_vars;
        build_kernel_work_cmds;
        build_kernel_work_env;
    }

    build_kernel_exec() {
        build_kernel_exec_work() {
            cd "$KL_DIR"
            cd_rc=$(printf "%d" "$?")

            if [ $cd_rc -ne 0 ]; then
                script_death "cd" "${cd_rc}" "$LINENO" "" "" ""
            fi

            if [ $CLEAN_BUILD -eq 1 ]; then
                if [ -d "$kl_out_dir" ]; then
                    rm -rf "$kl_out_dir"
                fi

                if [ -f "$kl_conf_obj" ]; then
                    (unset KBUILD_OUTPUT; make clean && make mrproper)
                fi
            fi

            dsstart=$(date +%s)
        }

        build_kernel_exec_gcc() {
            CC="${gcc_loc}"

            if [ $CCACHE -eq 1 ]; then
                CC="${ccache_loc} ${CC}"
            fi

            if [ -n "$TC_DIR" ]; then
                make $kl_conf_make \
                     -j${cpu_avl_cores}
            else
                make CC="${CC}" \
                     $kl_conf_make \
                     -j${cpu_avl_cores}
            fi

            make_rc=$(printf "%d" "$?")

            if [ $make_rc -ne 0 ]; then
                script_death "make" "${make_rc}" "" "Cannot generate .config" \
                             "" ""
            fi

            if [ -n "$TC_DIR" ]; then
                make -j${cpu_avl_cores}
            else
                make CC="${CC}" \
                     -j${cpu_avl_cores}
            fi

            make_rc=$(printf "%d" "$?")

            if [ $make_rc -ne 0 ]; then
                script_death "make" "${make_rc}" "" "Compilation has errors" \
                             "" ""
            fi
        }

        build_kernel_exec_post() {
            dsend=$(date +%s)
            bfdate=$(date "+%b %-e, %T %:z")
        }

        build_kernel_exec_work;
        build_kernel_exec_gcc;
        build_kernel_exec_post;
    }

    build_kernel_work;
    build_kernel_exec;
}

report() {
    report_work() {
        echo
    }

    report_success() {
        text_clr "green"
        echo "The kernel is compiled successfully!"
        text_clr "def"
    }

    report_work;
    report_success;
}

stats() {
    stats_work() {
        echo
        text_clr "white"
    }

    stats_user() {
        printf "> User: %s" "${KBUILD_BUILD_USER}"
        echo
    }

    stats_host() {
        printf "> Host: %s" "${KBUILD_BUILD_HOST}"
        echo
    }

    stats_comp() {
        stats_comp_work() {
            comp_time=$((dsend - dsstart))
            comp_time_mins=$((comp_time / 60))
            comp_time_secs=$((comp_time % 60))
            comp_time_mins_noun=minutes
            comp_time_secs_noun=seconds

            if [ $comp_time_mins -eq 1 ]; then
                comp_time_mins_noun=minute
            fi

            if [ $comp_time_secs -eq 1 ]; then
                comp_time_secs_noun=second
            fi
        }

        stats_comp_exec() {
            printf "> Compilation took: %d %s and %d %s" \
                   "${comp_time_mins}" \
                   "${comp_time_mins_noun}" \
                   "${comp_time_secs}" \
                   "${comp_time_secs_noun}"
            echo

            printf "> Compilation finished at: %s" "${bfdate}"
            echo
        }

        stats_comp_work;
        stats_comp_exec;
    }

    stats_post() {
        text_clr "def"
    }

    stats_work;
    stats_user;
    stats_host;
    stats_comp;
    stats_post;
}

finish() {
    echo
}

variables;
helpers;
probe_vars;
env_check;
pkg_check;
build_kernel;
report;
stats;
finish;
