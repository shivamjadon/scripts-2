#!/bin/bash

: <<'notice'
 *
 * Script information:
 * Installs essential packages for kernel building.
 * Indentation space is 4 and is space characters.
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
    red='\033[1;31m'
    green='\033[1;32m'
    white='\033[1;37m'
    darkcyan='\033[0;36m'
    darkwhite='\033[0;37m'
}

function packages() {
    start1=$(date +'%s')
    printf "\n%b===========================================%b\n" "$darkcyan" "$darkwhite"

    if command -v automake > /dev/null 2>&1; then
        printf "%bautomake OK%b\n" "$green" "$darkwhite"
    else
        printf "%bautomake not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install automake > /dev/null 2>&1
    fi

    if command -v bison > /dev/null 2>&1; then
        printf "%bbison OK%b\n" "$green" "$darkwhite"
    else
        printf "%bbison not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install bison > /dev/null 2>&1
    fi

    if dpkg -s build-essential | grep -q "ok"; then
        printf "%bbuild-essential OK%b\n" "$green" "$darkwhite"
    else
        printf "%bbuild-essential not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install build-essential > /dev/null 2>&1
    fi

    if command -v bzip2 > /dev/null 2>&1; then
        printf "%bbzip2 OK%b\n" "$green" "$darkwhite"
    else
        printf "%bbzip2 not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install bzip2 > /dev/null 2>&1
    fi

    if command -v ccache > /dev/null 2>&1; then
        printf "%bccache OK%b\n" "$green" "$darkwhite"
    else
        printf "%bccache not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install ccache > /dev/null 2>&1
    fi

    if command -v curl > /dev/null 2>&1; then
        printf "%bcurl OK%b\n" "$green" "$darkwhite"
    else
        printf "%bcurl not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install curl > /dev/null 2>&1
    fi

    if dpkg -s dpkg-dev | grep -q "ok"; then
        printf "%bdpkg-dev OK%b\n" "$green" "$darkwhite"
    else
        printf "%bdpkg-dev not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install dpkg-dev > /dev/null 2>&1
    fi

    if dpkg -s g++-multilib | grep -q "ok"; then
        printf "%bg++-multilib OK%b\n" "$green" "$darkwhite"
    else
        printf "%bg++-multilib not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install g++-multilib > /dev/null 2>&1
    fi

    if command -v git > /dev/null 2>&1; then
        printf "%bgit OK%b\n" "$green" "$darkwhite"
    else
        printf "%bgit not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install git > /dev/null 2>&1
    fi

    if command -v gperf > /dev/null 2>&1; then
        printf "%bgperf OK%b\n" "$green" "$darkwhite"
    else
        printf "%bgperf not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install gperf > /dev/null 2>&1
    fi

    if dpkg -s libbz2-1.0 | grep -q "ok"; then
        printf "%blibbz2-1.0 OK%b\n" "$green" "$darkwhite"
    else
        printf "%blibbz2-1.0 not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install libbz2-1.0 > /dev/null 2>&1
    fi

    if dpkg -s libbz2-dev | grep -q "ok"; then
        printf "%blibbz2-dev OK%b\n" "$green" "$darkwhite"
    else
        printf "%blibbz2-dev not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install libbz2-dev > /dev/null 2>&1
    fi

    if dpkg -s libfl-dev | grep -q "ok"; then
        printf "%blibfl-dev OK%b\n" "$green" "$darkwhite"
    else
        printf "%blibfl-dev not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install libfl-dev > /dev/null 2>&1
    fi

    if dpkg -s libghc-bzlib-dev | grep -q "ok"; then
        printf "%blibghc-bzlib-dev OK%b\n" "$green" "$darkwhite"
    else
        printf "%blibghc-bzlib-dev not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install libghc-bzlib-dev > /dev/null 2>&1
    fi

    if dpkg -s liblz4-tool | grep -q "ok"; then
        printf "%bliblz4-tool OK%b\n" "$green" "$darkwhite"
    else
        printf "%bliblz4-tool not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install liblz4-tool > /dev/null 2>&1
    fi

    if dpkg -s libxml2-utils | grep -q "ok"; then
        printf "%blibxml2-utils OK%b\n" "$green" "$darkwhite"
    else
        printf "%blibxml2-utils not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install libxml2-utils > /dev/null 2>&1
    fi

    if command -v lzop > /dev/null 2>&1; then
        printf "%blzop OK%b\n" "$green" "$darkwhite"
    else
        printf "%blzop not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install lzop > /dev/null 2>&1
    fi

    if command -v make > /dev/null 2>&1; then
        printf "%bmake OK%b\n" "$green" "$darkwhite"
    else
        printf "%bmake not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install make > /dev/null 2>&1
    fi

    if command -v optipng > /dev/null 2>&1; then
        printf "%boptipng OK%b\n" "$green" "$darkwhite"
    else
        printf "%boptipng not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install optipng > /dev/null 2>&1
    fi

    if command -v pngcrush > /dev/null 2>&1; then
        printf "%bpngcrush OK%b\n" "$green" "$darkwhite"
    else
        printf "%bpngcrush not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install pngcrush > /dev/null 2>&1
    fi

    if dpkg -s python-networkx | grep -q "ok"; then
        printf "%bpython-networkx OK%b\n" "$green" "$darkwhite"
    else
        printf "%bpython-networkx not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install python-networkx > /dev/null 2>&1
    fi

    if command -v schedtool > /dev/null 2>&1; then
        printf "%bschedtool OK%b\n" "$green" "$darkwhite"
    else
        printf "%bschedtool not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install schedtool > /dev/null 2>&1
    fi

    if dpkg -s squashfs-tools | grep -q "ok"; then
        printf "%bsquashfs-tools OK%b\n" "$green" "$darkwhite"
    else
        printf "%bsquashfs-tools not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install squashfs-tools > /dev/null 2>&1
    fi

    if command -v zip > /dev/null 2>&1; then
        printf "%bzip OK%b\n" "$green" "$darkwhite"
    else
        printf "%bzip not found! %bInstalling it...%b\n" "$red" "$green" "$darkwhite"
        apt-get --yes --force-yes install zip > /dev/null 2>&1
    fi

    printf "%b===========================================%b\n\n" "$darkcyan" "$darkwhite"
    end1=$(date +'%s')
    installtime=$((end1-start1))
}

function stats() {
    if [ "$installtime" = "0" ] || [ "$installtime" = "1" ] || [ "$installtime" = "2" ] ; then
        printf " %b> The packages are already installed!%b\n\n" "$white" "$darkwhite"
    else
        printf " %b> Installing the packages took %d seconds.%b\n\n" "$white" "$installtime" "$darkwhite"
    fi
}

get_sudo "$@"
variables
packages
stats
