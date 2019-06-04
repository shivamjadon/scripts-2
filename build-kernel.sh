#!/bin/bash

<<notice
 *
 * Script information:
 * Kernel building script.
 * Indentation space is tab characters.
 * Clang compilation is not supported (yet).
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

# Variables that have to be defined by the user
function variables() {
		TOOLCHAIN_REPO=
		TOOLCHAIN_BRANCH=
		TOOLCHAIN_DIR_NAME=
		TOOLCHAIN_DIR_PREFIX=
		TOOLCHAIN_NAME=
		AK_REPO=
		AK_BRANCH=
		AK_DIR_NAME=
		AK_NAME=
		KERNEL_REPO=
		KERNEL_BRANCH=
		KERNEL_DIR=
		KERNEL_NAME=
		KERNEL_DEFCONFIG=
		KERNEL_ANDROID_BASE_VER=
		### AK additional variables
		AK_ZIP_KERNEL_NAME=
		### Kernel additional variables
		KERNEL_OUT_DIR=
		### Variables for out compilation
		KERNEL_BUILD_USER=
		KERNEL_BUILD_HOST=
		KERNEL_ARCH=
		KERNEL_SUBARCH=
}

# Setting up additional variables
function addvars() {
	red='\033[1;31m'
	green='\033[1;32m'
	white='\033[1;37m'
	cyan='\033[1;36m'
	darkcyan='\033[0;36m'
	darkwhite='\033[0;37m'
	sleep_value_after_clone=0.2
	current_date=$(date +'%Y%m%d')
}

# Shallow clone sources and tools
function cloning() {
	# Kernel
	printf "\n>>> Cloning ${cyan}${KERNEL_NAME}${darkwhite}...\n"
	git clone --branch ${KERNEL_BRANCH} --depth 1 ${KERNEL_REPO} $HOME/${KERNEL_DIR}
	sleep ${sleep_value_after_clone}

	# Toolchain
	printf "\n>>> Cloning ${cyan}${TOOLCHAIN_NAME}${darkwhite}...\n"
	git clone --branch ${TOOLCHAIN_BRANCH} --depth 1 ${TOOLCHAIN_REPO} $HOME/${TOOLCHAIN_DIR_NAME}
	sleep ${sleep_value_after_clone}

	# AK
	printf "\n>>> Cloning ${cyan}${AK_NAME}${darkwhite}...\n"
	git clone ${AK_REPO} -b ${AK_BRANCH} $HOME/${AK_DIR_NAME}
}

# Give choice depending on situation
function choices() {
	# Clean build for out compilation
	outfolder1=$HOME/${KERNEL_OUT_DIR}
		if [ -d "$outfolder1" ]; then
			printf "\n${white}Make clean (out) build?${darkwhite}\n"
			select yn in "Yes" "No"; do
				case $yn in
					Yes )
						rm -rf $HOME/${KERNEL_OUT_DIR}
						rm -rf $HOME/.ccache/* ; break;;
					No ) break;;
				esac
			done
		fi

	# Clean build for inline/standalone compilation
	inline1=$HOME/${KERNEL_DIR}/arch/arm64/crypto/built-in.o
		if [ -f "$inline1" ]; then
			printf "\n${white}Make clean (inline/standalone) build?${darkwhite}\n"
			select yn in "Yes" "No"; do
				case $yn in
					Yes )
						rm -rf $HOME/.ccache/*
						cd $HOME/${KERNEL_DIR}
						make clean
						make mrproper ; break;;
					No ) break;;
				esac
			done
		fi

	# Clean the AK directory
	zImage1=$HOME/${AK_DIR_NAME}/zImage
		if [ -f "$zImage1" ]; then
			printf "\n${white}Clean ${AK_DIR_NAME} folder?${darkwhite}\n"
			select yn in "Yes" "No"; do
				case $yn in
					Yes )
						find $HOME/${AK_DIR_NAME} -name "*$KERNEL_NAME*" -type f -exec rm -f {} \;
						find $HOME/${AK_DIR_NAME} -name "zImage" -type f -exec rm -f {} \; ; break;;
					No ) break;;
				esac
			done
		fi

	# Compilation type
	out=hahayeslogic
		printf "\n${white}Compilation type:${darkwhite}\n"
		select oi in "Out" "Inline/Standalone"; do
			case $oi in
				Out ) unset out; break;;
				Inline/Standalone ) break;;
			esac
		done
	echo
}

# Compile the kernel
function compilation() {
	start1=$SECONDS
		if [ -z "$out" ]; then
			cd $HOME/${KERNEL_DIR}

			# Export
			export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
			export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
			export ARCH=${KERNEL_ARCH}
			export SUBARCH=${KERNEL_SUBARCH}
			export CROSS_COMPILE="ccache $HOME/${TOOLCHAIN_DIR_NAME}/bin/${TOOLCHAIN_DIR_PREFIX}"

			# Build
			make O=$HOME/${KERNEL_OUT_DIR} \
				ARCH=${KERNEL_ARCH} \
				${KERNEL_DEFCONFIG}

			make O=$HOME/${KERNEL_OUT_DIR} \
				ARCH=${KERNEL_ARCH} \
				-j$(nproc --all)
		elif [ -n "$out" ]; then
			cd $HOME/${KERNEL_DIR}

			# Export
			CROSS_COMPILE="ccache $HOME/${TOOLCHAIN_DIR_NAME}/bin/${TOOLCHAIN_DIR_PREFIX}"
			export ARCH=${KERNEL_ARCH} && export SUBARCH=${KERNEL_SUBARCH} && make ${KERNEL_DEFCONFIG}

			# Build
			CROSS_COMPILE=$CROSS_COMPILE make -j$( nproc --all )
		fi
	end1=$SECONDS
}

# Check if compilation is successful
function compilationreport() {
	imagelogic1=$HOME/${KERNEL_OUT_DIR}/arch/arm64/boot/Image.gz-dtb
	imagelogic2=$HOME/${KERNEL_DIR}/arch/arm64/boot/Image.gz-dtb
		if [ -d "$outfolder1" ] &&  [ -n "$imagelogic1" ] || [ -f "${inline1}" ] && [ -n "${imagelogic2}" ]; then
			printf "\n${red}The kernel was not compiled correctly, check the log for errors.\nAborting further operations...${darkwhite}\n\n"
			exit 1;
		fi
}

# Build kernel zip
function zipbuilder() {
	start2=$SECONDS
	kernel_version=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')
	FILE_NAME="${AK_ZIP_KERNEL_NAME}-v${kernel_version}-${KERNEL_ANDROID_BASE_VER}-${current_date}.zip"
		if [ -d "$outfolder1" ]; then
			cp $HOME/${KERNEL_OUT_DIR}/arch/arm64/boot/Image.gz-dtb $HOME/${AK_DIR_NAME}/zImage
		elif [ -f "$inline1" ]; then
			cp $HOME/${KERNEL_DIR}/arch/arm64/boot/Image.gz-dtb $HOME/${AK_DIR_NAME}/zImage
		fi
	printf "\n ${white}> Packing ${cyan}${KERNEL_NAME} $kernel_version ${white}kernel...${darkwhite}\n\n"
		pushd $HOME/${AK_DIR_NAME}
			zip -r9 ${FILE_NAME} * -x .git README.md
		popd
	end2=$SECONDS
}

# Print statistics
function stats() {
	echo
		printf " ${white}> File location: ${green}$HOME/${AK_DIR_NAME}/$FILE_NAME\n"
		printf "\n ${darkcyan}> Compiling the kernel was completed in ${white}$((end1-start1))${darkcyan} seconds.${darkwhite}"
		if [ "$((end2-start2))" = "1" ]; then
			printf "\n ${darkcyan}> Packing the kernel was completed in ${white}$((end2-start2))${darkcyan} second.${darkwhite}"
		else
			printf "\n ${darkcyan}> Packing the kernel was completed in ${white}$((end2-start2))${darkcyan} seconds.${darkwhite}\n"
		fi
}

variables
addvars
cloning
choices
compilation
compilationreport
zipbuilder
stats
