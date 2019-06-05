#!/bin/bash

<<notice
 *
 * Script information:
 * Installs essential packages for kernel building.
 * Indentation space is tab characters.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

# Set colors
function colors() {
	red='\033[1;31m'
	green='\033[1;32m'
	white='\033[1;37m'
	darkcyan='\033[0;36m'
	darkwhite='\033[0;37m'
}

# Install the packages
function packages() {
	start1=$SECONDS
	printf "\n${darkcyan}===========================================${darkwhite}"
		automake=$(command -v automake);
		if [ "$?" = "0" ]; then
			printf "\n${green}automake OK${darkwhite}"
		else
			printf "\n${red}automake not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install automake > /dev/null 2>&1
		fi
		bison=$(command -v bison);
		if [ "$?" = "0" ]; then
			printf "\n${green}bison OK${darkwhite}"
		else
			printf "\n${red}bison not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install bison > /dev/null 2>&1
		fi
		if dpkg -s build-essential | grep -q "ok"; then
			printf "\n${green}build-essential OK${darkwhite}"
		else
			printf "\n${red}build-essential not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install build-essential > /dev/null 2>&1
		fi
		bzip2=$(command -v bzip2);
		if [ "$?" = "0" ]; then
			printf "\n${green}bzip2 OK${darkwhite}"
		else
			printf "\n${red}bzip2 not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install bzip2 > /dev/null 2>&1
		fi
		ccache=$(command -v ccache);
		if [ "$?" = "0" ]; then
			printf "\n${green}ccache OK${darkwhite}"
		else
			printf "\n${red}ccache not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install ccache > /dev/null 2>&1
		fi
		curl=$(command -v curl);
		if [ "$?" = "0" ]; then
			printf "\n${green}curl OK${darkwhite}"
		else
			printf "\n${red}curl not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install curl > /dev/null 2>&1
		fi
		if dpkg -s dpkg-dev | grep -q "ok"; then
			printf "\n${green}dpkg-dev OK${darkwhite}"
		else
			printf "\n${red}dpkg-dev not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install dpkg-dev > /dev/null 2>&1
		fi
		if dpkg -s g++-multilib | grep -q "ok"; then
			printf "\n${green}g++-multilib OK${darkwhite}"
		else
			printf "\n${red}g++-multilib not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install g++-multilib > /dev/null 2>&1
		fi
		git=$(command -v git);
		if [ "$?" = "0" ]; then
			printf "\n${green}git OK${darkwhite}"
		else
			printf "\n${red}git not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install git > /dev/null 2>&1
		fi
		gperf=$(command -v gperf);
		if [ "$?" = "0" ]; then
			printf "\n${green}gperf OK${darkwhite}"
		else
			printf "\n${red}gperf not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install gperf > /dev/null 2>&1
		fi
		if dpkg -s libbz2-1.0 | grep -q "ok"; then
			printf "\n${green}libbz2-1.0 OK${darkwhite}"
		else
			printf "\n${red}libbz2-1.0 not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install libbz2-1.0 > /dev/null 2>&1
		fi
		if dpkg -s libbz2-dev | grep -q "ok"; then
			printf "\n${green}libbz2-dev OK${darkwhite}"
		else
			printf "\n${red}libbz2-dev not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install libbz2-dev > /dev/null 2>&1
		fi
		if dpkg -s libfl-dev | grep -q "ok"; then
			printf "\n${green}libfl-dev OK${darkwhite}"
		else
			printf "\n${red}libfl-dev not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install libfl-dev > /dev/null 2>&1
		fi
		if dpkg -s libghc-bzlib-dev | grep -q "ok"; then
			printf "\n${green}libghc-bzlib-dev OK${darkwhite}"
		else
			printf "\n${red}libghc-bzlib-dev not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install libghc-bzlib-dev > /dev/null 2>&1
		fi
		if dpkg -s liblz4-tool | grep -q "ok"; then
			printf "\n${green}liblz4-tool OK${darkwhite}"
		else
			printf "\n${red}liblz4-tool not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install liblz4-tool > /dev/null 2>&1
		fi
		if dpkg -s libxml2-utils | grep -q "ok"; then
			printf "\n${green}libxml2-utils OK${darkwhite}"
		else
			printf "\n${red}libxml2-utils not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install libxml2-utils > /dev/null 2>&1
		fi
		lzop=$(command -v lzop);
		if [ "$?" = "0" ]; then
			printf "\n${green}lzop OK${darkwhite}"
		else
			printf "\n${red}lzop not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install lzop > /dev/null 2>&1
		fi
		make=$(command -v make);
		if [ "$?" = "0" ]; then
			printf "\n${green}make OK${darkwhite}"
		else
			printf "\n${red}make not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install make > /dev/null 2>&1
		fi
		optipng=$(command -v optipng);
		if [ "$?" = "0" ]; then
			printf "\n${green}optipng OK${darkwhite}"
		else
			printf "\n${red}optipng not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install optipng > /dev/null 2>&1
		fi
		pngcrush=$(command -v pngcrush);
		if [ "$?" = "0" ]; then
			printf "\n${green}pngcrush OK${darkwhite}"
		else
			printf "\n${red}pngcrush not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install pngcrush > /dev/null 2>&1
		fi
		if dpkg -s python-networkx | grep -q "ok"; then
			printf "\n${green}python-networkx OK${darkwhite}"
		else
			printf "\n${red}python-networkx not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install python-networkx > /dev/null 2>&1
		fi
		schedtool=$(command -v schedtool);
		if [ "$?" = "0" ]; then
			printf "\n${green}schedtool OK${darkwhite}"
		else
			printf "\n${red}schedtool not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install schedtool > /dev/null 2>&1
		fi
		if dpkg -s squashfs-tools | grep -q "ok"; then
			printf "\n${green}squashfs-tools OK${darkwhite}"
		else
			printf "\n${red}squashfs-tools not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install squashfs-tools > /dev/null 2>&1
		fi
		zip=$(command -v zip);
		if [ "$?" = "0" ]; then
			printf "\n${green}zip OK${darkwhite}"
		else
			printf "\n${red}zip not found! ${green}Installing it...${darkwhite}"
			sudo -u root apt-get --yes --force-yes install zip > /dev/null 2>&1
		fi
	printf "\n${darkcyan}===========================================${darkwhite}\n"
	end1=$SECONDS
}

# Print statistics
function stats() {
		if [ "$((end1-start1))" = "0" ] || [ "$((end1-start1))" = "1" ]; then
			printf "\n > ${green}All packages are already installed!${darkwhite}"
		else
			printf "\n ${darkcyan}> Installing the packages was completed in ${white}$((end1-start1))${darkcyan} seconds.${darkwhite}"
		fi
}

colors
packages
stats
