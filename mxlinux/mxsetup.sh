#!/bin/bash

: <<'notice'
 *
 * SPDX-License-Identifier: GPL-3.0
 * 
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

function get_sudo() {
    if [ $EUID != 0 ]; then
        sudo "$0"
        exit $?
    fi
}

function variables() {

    function tweak() {
        # VM
        swappiness=10
        vfs_cache_pressure=50
    }

    function script() {
        # Toggles
        tweak_memory=0
        remove_bloatware=0
        install_software=1
        
        # Behaviour
        verbose_operations=0 # NOTE: Very verbose.
    }

    function misc() {
        white='\033[1;37m'
        darkwhite='\033[0;37m'
        work_dir=$(pwd)
        start1=$(date +'%s')
    }

tweak
script
misc
}

function log_file() {
    LOG=${work_dir}/mxsetuplog.txt
    rm -f "$LOG"
    touch "$LOG"
}

function check_os() {
    mx=$(uname -n)
    memory=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
    memcut=${memory%??????}
    if [ "$mx" != "mx" ]; then
        os_info=$(uname -a)
        {
            printf "Your OS is not compatible.\n"
            printf "%s\n" "$os_info"
        } >> "$LOG"
        printf "\n%bYou are not using MX Linux. Aborting further operations...%b\n\n" "$white" "$darkwhite"
        printf "%b> Log location: %s\n\n" "$white" "$LOG"
        kill $$
        exit 1
    elif [ "$memcut" != 1 ] && [ "$memcut" != 2 ]; then
        os_info=$(uname -a)
        {
            printf "Your OS is compatible.\n"
            printf "%s\n" "$os_info"
            printf "Your RAM (%d GB) is not compatible though.\n" "$memcut"
        } >> "$LOG"
        printf "\n%bThis script is not for your %d GB RAM computer. Aborting further operations...%b\n\n" "$white" "$memcut" "$darkwhite"
        printf "%b> Log location: %s\n\n" "$white" "$LOG"
        kill $$
        exit 1
    else
        os_info=$(uname -a)
        {
            printf "Your computer passed the compatibility check.\n"
            printf "%s\n" "$os_info"
            printf "%d GB RAM\n" "$memcut"
        } >> "$LOG"
    fi
}

function tweak_memory() {
    {
        printf "\nMemory tweak.\n"
        printf "Path: /etc/sysctl.conf\n"
        printf "======================\n"
    } >> "$LOG"

    if grep -Fq "MXSETUP" /etc/sysctl.conf; then
        printf "MXS = YES\n" >> "$LOG"
    else
        printf "\n" >> /etc/sysctl.conf
        printf "# MXSETUP" >> /etc/sysctl.conf
        printf "MXS = INSERTED\n" >> "$LOG"
    fi

    if grep -Fq "vm.swappiness" /etc/sysctl.conf; then
        if grep -Fq "vm.swappiness=$swappiness" /etc/sysctl.conf; then
            printf "vm.swappiness = LATEST (%d)\n" "$swappiness" >> "$LOG"
        else
            swapold=$(grep vm.swappiness /etc/sysctl.conf | cut -d "=" -f2)
            swapnew=${swappiness}
            sed '/vm.swappiness/d' /etc/sysctl.conf > /etc/sysctl2.conf
            rm -f /etc/sysctl.conf
            mv /etc/sysctl2.conf /etc/sysctl.conf
            printf "vm.swappiness=%d\n" "$swappiness" >> /etc/sysctl.conf
            chmod 644 /etc/sysctl.conf
            printf "vm.swappiness = UPDATED (%d to %d)\n" "$swapold" "$swapnew" >> "$LOG"
        fi
    else
        printf "vm.swappiness=%d\n" "$swappiness" >> /etc/sysctl.conf
        printf "vm.swappiness = INSERTED (%d)\n" "$swappiness" >> "$LOG"
    fi

    if grep -Fq "vm.vfs_cache_pressure" /etc/sysctl.conf; then
        if grep -Fq "vm.vfs_cache_pressure=$vfs_cache_pressure" /etc/sysctl.conf; then
            printf "vm.vfs_cache_pressure = LATEST (%d)\n" "$vfs_cache_pressure" >> "$LOG"
        else
            vfscpold=$(grep vm.vfs_cache_pressure /etc/sysctl.conf | cut -d "=" -f2)
            vfscpnew=${vfs_cache_pressure}
            sed '/vm.vfs_cache_pressure/d' /etc/sysctl.conf > /etc/sysctl2.conf
            rm -f /etc/sysctl.conf
            mv /etc/sysctl2.conf /etc/sysctl.conf
            printf "vm.vfs_cache_pressure=%d\n" "$vfs_cache_pressure" >> /etc/sysctl.conf
            chmod 644 /etc/sysctl.conf
            printf "vm.vfs_cache_pressure = UPDATED (%d to %d)\n" "$vfscpold" "$vfscpnew" >> "$LOG"
        fi
    else
        printf "vm.vfs_cache_pressure=%d\n" "$vfs_cache_pressure" >> /etc/sysctl.conf
        printf "vm.vfs_cache_pressure = INSERTED (%d)\n" "$vfs_cache_pressure" >> "$LOG"
    fi
}

function remove_bloatware() {
    {
        printf "\nRemoving bloatware...\n"
        printf "=====================\n"
        printf "Removing: apt-xapian-index, gnome-orca, ndiswrapper*, mobile-broadband-provider-info, et cetera.\n"
    } >> "$LOG"

    if [ "$verbose_operations" = 0 ]; then
        apt-get --yes --force-yes remove apt-xapian-index mono-runtime-common gnome-orca ndiswrapper* gnome-schedule gscan2pdf hplip hplip-data lightning simple-scan printer-driver-gutenprint printer-driver-postscript-hp sane-utils thunderbird vim-tiny mobile-broadband-provider-info > /dev/null 2>&1
    else
        apt-get --yes --force-yes remove apt-xapian-index mono-runtime-common gnome-orca ndiswrapper* gnome-schedule gscan2pdf hplip hplip-data lightning simple-scan printer-driver-gutenprint printer-driver-postscript-hp sane-utils thunderbird vim-tiny mobile-broadband-provider-info
    fi

    if [ "$verbose_operations" = 0 ]; then
        apt --yes --force-yes autoremove > /dev/null 2>&1
    else
        apt --yes --force-yes autoremove
    fi
}

function install_software() {
    {
        printf "\nInstalling software...\n"
        printf "======================\n"
        printf "Installing: Kernel and ROM building tools, adb, fastboot, et cetera.\n"
    } >> "$LOG"

    if [ "$verbose_operations" = 0 ]; then
        apt-get --yes --force-yes update > /dev/null 2>&1
    else
        apt-get --yes --force-yes update
    fi

    if [ "$verbose_operations" = 0 ]; then
        apt-get --yes --force-yes ugrade > /dev/null 2>&1
    else
        apt-get --yes --force-yes ugrade
    fi

    if [ "$verbose_operations" = 0 ]; then
        apt-get --yes --force-yes install adb fastboot libfl-dev texinfo gcc-multilib autopoint autoconf subversion expat libtool lib32ncurses5-dev lib32readline-dev lib32z1-dev python-all-dev libesd0-dev liblzma-dev binutils-dev xsltproc ccache automake lzop bison gperf libcap-dev txt2man g++-multilib python-networkx libxml2-utils libgmp-dev libbz2-dev libghc-bzlib-dev libssl-dev pngcrush schedtool liblz4-tool optipng bum > /dev/null 2>&1
    else
        apt-get --yes --force-yes install adb fastboot libfl-dev texinfo gcc-multilib autopoint autoconf subversion expat libtool lib32ncurses5-dev lib32readline-dev lib32z1-dev python-all-dev libesd0-dev liblzma-dev binutils-dev xsltproc ccache automake lzop bison gperf libcap-dev txt2man g++-multilib python-networkx libxml2-utils libgmp-dev libbz2-dev libghc-bzlib-dev libssl-dev pngcrush schedtool liblz4-tool optipng bum
    fi

    if [ "$verbose_operations" = 0 ]; then
        apt --yes --force-yes autoremove > /dev/null 2>&1
    else
        apt --yes --force-yes autoremove
    fi
}

function finish() {
    end1=$(date +'%s')
    elapsed=$((end1-start1))
    {
        printf "\nThe script finished execution.\n"
        printf "Elapsed time: %d seconds.\n" "$elapsed"
    } >> "$LOG"
    printf "\n%b> Log location: %s\n\n" "$white" "$LOG"
}

get_sudo "$@"
variables
log_file
check_os
if [ "$tweak_memory" = 1 ]; then
    tweak_memory
fi
if [ "$remove_bloatware" = 1 ]; then
    remove_bloatware
fi
if [ "$install_software" = 1 ]; then
    install_software
fi
finish
