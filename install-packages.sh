#!/bin/bash

<<notice
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
        sudo "$0" "$@"
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
    printf "\n${darkcyan}===========================================${darkwhite}\n"
        automake=$(command -v automake);
        if [ "$?" = "0" ]; then
            printf "${green}automake OK${darkwhite}\n"
        else
            printf "${red}automake not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install automake > /dev/null 2>&1
        fi
        bison=$(command -v bison);
        if [ "$?" = "0" ]; then
            printf "${green}bison OK${darkwhite}\n"
        else
            printf "${red}bison not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install bison > /dev/null 2>&1
        fi
        if dpkg -s build-essential | grep -q "ok"; then
            printf "${green}build-essential OK${darkwhite}\n"
        else
            printf "${red}build-essential not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install build-essential > /dev/null 2>&1
        fi
        bzip2=$(command -v bzip2);
        if [ "$?" = "0" ]; then
            printf "${green}bzip2 OK${darkwhite}\n"
        else
            printf "${red}bzip2 not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install bzip2 > /dev/null 2>&1
        fi
        ccache=$(command -v ccache);
        if [ "$?" = "0" ]; then
            printf "${green}ccache OK${darkwhite}\n"
        else
            printf "${red}ccache not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install ccache > /dev/null 2>&1
        fi
        curl=$(command -v curl);
        if [ "$?" = "0" ]; then
            printf "${green}curl OK${darkwhite}\n"
        else
            printf "${red}curl not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install curl > /dev/null 2>&1
        fi
        if dpkg -s dpkg-dev | grep -q "ok"; then
            printf "${green}dpkg-dev OK${darkwhite}\n"
        else
            printf "${red}dpkg-dev not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install dpkg-dev > /dev/null 2>&1
        fi
        if dpkg -s g++-multilib | grep -q "ok"; then
            printf "${green}g++-multilib OK${darkwhite}\n"
        else
            printf "${red}g++-multilib not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install g++-multilib > /dev/null 2>&1
        fi
        git=$(command -v git);
        if [ "$?" = "0" ]; then
            printf "${green}git OK${darkwhite}\n"
        else
            printf "${red}git not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install git > /dev/null 2>&1
        fi
        gperf=$(command -v gperf);
        if [ "$?" = "0" ]; then
            printf "${green}gperf OK${darkwhite}\n"
        else
            printf "${red}gperf not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install gperf > /dev/null 2>&1
        fi
        if dpkg -s libbz2-1.0 | grep -q "ok"; then
            printf "${green}libbz2-1.0 OK${darkwhite}\n"
        else
            printf "${red}libbz2-1.0 not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install libbz2-1.0 > /dev/null 2>&1
        fi
        if dpkg -s libbz2-dev | grep -q "ok"; then
            printf "${green}libbz2-dev OK${darkwhite}\n"
        else
            printf "${red}libbz2-dev not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install libbz2-dev > /dev/null 2>&1
        fi
        if dpkg -s libfl-dev | grep -q "ok"; then
            printf "${green}libfl-dev OK${darkwhite}\n"
        else
            printf "${red}libfl-dev not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install libfl-dev > /dev/null 2>&1
        fi
        if dpkg -s libghc-bzlib-dev | grep -q "ok"; then
            printf "${green}libghc-bzlib-dev OK${darkwhite}\n"
        else
            printf "${red}libghc-bzlib-dev not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install libghc-bzlib-dev > /dev/null 2>&1
        fi
        if dpkg -s liblz4-tool | grep -q "ok"; then
            printf "${green}liblz4-tool OK${darkwhite}\n"
        else
            printf "${red}liblz4-tool not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install liblz4-tool > /dev/null 2>&1
        fi
        if dpkg -s libxml2-utils | grep -q "ok"; then
            printf "${green}libxml2-utils OK${darkwhite}\n"
        else
            printf "${red}libxml2-utils not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install libxml2-utils > /dev/null 2>&1
        fi
        lzop=$(command -v lzop);
        if [ "$?" = "0" ]; then
            printf "${green}lzop OK${darkwhite}\n"
        else
            printf "${red}lzop not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install lzop > /dev/null 2>&1
        fi
        make=$(command -v make);
        if [ "$?" = "0" ]; then
            printf "${green}make OK${darkwhite}\n"
        else
            printf "${red}make not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install make > /dev/null 2>&1
        fi
        optipng=$(command -v optipng);
        if [ "$?" = "0" ]; then
            printf "${green}optipng OK${darkwhite}\n"
        else
            printf "${red}optipng not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install optipng > /dev/null 2>&1
        fi
        pngcrush=$(command -v pngcrush);
        if [ "$?" = "0" ]; then
            printf "${green}pngcrush OK${darkwhite}\n"
        else
            printf "${red}pngcrush not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install pngcrush > /dev/null 2>&1
        fi
        if dpkg -s python-networkx | grep -q "ok"; then
            printf "${green}python-networkx OK${darkwhite}\n"
        else
            printf "${red}python-networkx not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install python-networkx > /dev/null 2>&1
        fi
        schedtool=$(command -v schedtool);
        if [ "$?" = "0" ]; then
            printf "${green}schedtool OK${darkwhite}\n"
        else
            printf "${red}schedtool not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install schedtool > /dev/null 2>&1
        fi
        if dpkg -s squashfs-tools | grep -q "ok"; then
            printf "${green}squashfs-tools OK${darkwhite}\n"
        else
            printf "${red}squashfs-tools not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install squashfs-tools > /dev/null 2>&1
        fi
        zip=$(command -v zip);
        if [ "$?" = "0" ]; then
            printf "${green}zip OK${darkwhite}\n"
        else
            printf "${red}zip not found! ${green}Installing it...${darkwhite}\n"
            apt-get --yes --force-yes install zip > /dev/null 2>&1
        fi
    printf "${darkcyan}===========================================${darkwhite}\n\n"
    end1=$(date +'%s')
    installtime=$(($end1-$start1))
}

function stats() {
        if [ "$installtime" = "0" ] || [ "$installtime" = "1" ] || [ "$installtime" = "2" ] ; then
            printf " ${white}> The packages are already installed!${darkwhite}\n\n"
        else
            printf " ${white}> Installing the packages took ${installtime} seconds.${darkwhite}\n\n"
        fi
}

get_sudo
variables
packages
stats
