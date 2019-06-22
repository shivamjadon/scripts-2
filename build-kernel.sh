#!/bin/bash

<<notice
 *
 * Script information:
 * Noob friendly kernel building script.
 * Indentation space (4) is tab characters.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

# Variables that have to be defined by the user
function variables() {
		# Essential variables
		# NOTE: Do NOT use space in any variable, instead use dot (.) or dash (-).
		# NOTE: Leave REPO/BRANCH variables empty if you have them locally and not on Github or any similar host service. You can as well define and forget them, they will activate in case any source/tool is missing!
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
		KERNEL_OUT_DIR=
		KERNEL_NAME=
		KERNEL_DEFCONFIG=
		KERNEL_ARCH=
		KERNEL_SUBARCH=
		KERNEL_ANDROID_BASE_VER=

		# Optional variables
		KERNEL_BUILD_USER=
		KERNEL_BUILD_HOST=
		KERNEL_NAME_FOR_AK_ZIP=

		# Clang toolchain variables
		# NOTE: Do NOT touch any clang variables if you do NOT compile with Clang.
		# NOTE: If you are compiling with Clang, I recommend to use AOSP's GCC 4.9 to avoid both script and kernel problems.
		CLANG_REPO=
		CLANG_BRANCH=
		CLANG_DIR_NAME=
		CLANG_NAME=

		# Predefined variables
		# NOTE: You **probably** do NOT have to touch those.
		CLANG_BIN=clang
		CLANG_DIR_PREFIX=aarch64-linux-gnu-

		# Script control variables
		# NOTE: 1 - enabled. Anything else - disabled.
		STATS=1
		USE_CCACHE=1
		ZIP_BUILDER=1
		ASK_FOR_CLEAN_BUILD=1
		ASK_FOR_AK_CLEANING=1
		RECURSIVE_KERNEL_CLONE=0 # You need to enable this if your kernel has submodules.
		ASK_FOR_COMPILATION_METHOD=1 # If this is disabled, out folder is the default compilation method.
		MAKE_CLEAN_AND_MRPROPER_IN_KERNEL_DIR_WHILE_CLEANING=1

<<EXAMPLEandSYNTAX
	TOOLCHAIN_REPO=https://github.com/mscalindt/aarch64-linux-android-4.9.git
	TOOLCHAIN_BRANCH=master
	TOOLCHAIN_DIR_NAME=aarch64-linux-android-4.9
	TOOLCHAIN_DIR_PREFIX=aarch64-linux-android-
	TOOLCHAIN_NAME=AOSP-GCC-4.9
	KERNEL_DIR=android/mykernel
	KERNEL_OUT_DIR=android/mykernelout
	KERNEL_NAME=MyKernel
	KERNEL_ARCH=arm64
	KERNEL_SUBARCH=arm64
	KERNEL_ANDROID_BASE_VER=PIE
	KERNEL_NAME_FOR_AK_ZIP=Example.Kernel
	KERNEL_BUILD_USER=myusername
	KERNEL_BUILD_HOST=MyLinuxDistribution
	CLANG_DIR_NAME=clang-4691093
	CLANG_NAME=Clang-6.0
	USE_CCACHE=0
	or
	USE_CCACHE=hahanopls
EXAMPLEandSYNTAX
}

function addvars() {
	red='\033[1;31m'
	green='\033[1;32m'
	white='\033[1;37m'
	cyan='\033[1;36m'
	darkwhite='\033[0;37m'
	sleep_value_after_clone=0.2
	ak_clone_depth=1
	toolchain_clone_depth=1
	kernel_clone_depth=10
	current_date=$(date +'%Y%m%d')
	out=hahayeslogic
	inl=hahayeslogics
	clb1=$HOME/${KERNEL_OUT_DIR}
	clb2=$HOME/${KERNEL_DIR}/arch/arm64/crypto/built-in.o
	image1=$HOME/${KERNEL_OUT_DIR}/arch/arm64/boot/Image.gz-dtb
	image2=$HOME/${KERNEL_DIR}/arch/arm64/boot/Image.gz-dtb
	zImage1=$HOME/${AK_DIR_NAME}/zImage
}

function cloning() {
	if [ -n "$AK_REPO" ] && [ -n "$AK_BRANCH" ]; then
		if [ ! -d "$HOME/$AK_DIR_NAME" ]; then
			printf "\n>>> ${white}Cloning ${cyan}${AK_NAME}${darkwhite}...\n"
			git clone --branch ${AK_BRANCH} --depth ${ak_clone_depth} ${AK_REPO} "$HOME"/${AK_DIR_NAME}
		fi
	fi

	if [ -n "$TOOLCHAIN_REPO" ] && [ -n "$TOOLCHAIN_BRANCH" ]; then
		if [ -n "$CLANG_TC_REPO" ] && [ -n "$CLANG_TC_BRANCH" ]; then
			if [ ! -d "$HOME/$TOOLCHAIN_DIR_NAME" ] && [ ! -d "$HOME/$CLANG_DIR_NAME" ]; then
				printf "\n>>> ${white}Cloning ${cyan}${TOOLCHAIN_NAME}${darkwhite} ${white}+ ${cyan}${CLANG_NAME}${darkwhite}...\n"
				git clone --branch ${TOOLCHAIN_BRANCH} --depth ${toolchain_clone_depth} ${TOOLCHAIN_REPO} "$HOME"/${TOOLCHAIN_DIR_NAME}
				git clone --branch ${CLANG_BRANCH} --depth ${toolchain_clone_depth} ${CLANG_REPO} "$HOME"/${CLANG_DIR_NAME}
				sleep ${sleep_value_after_clone}
			elif [ ! -d "$HOME/$CLANG_DIR_NAME" ]; then
				printf "\n>>> ${white}Cloning ${cyan}${CLANG_NAME}${darkwhite}...\n"
				git clone --branch ${CLANG_BRANCH} --depth ${toolchain_clone_depth} ${CLANG_REPO} "$HOME"/${CLANG_DIR_NAME}
				sleep ${sleep_value_after_clone}
			fi
		elif [ ! -d "$HOME/$TOOLCHAIN_DIR_NAME" ]; then
			printf "\n>>> ${white}Cloning ${cyan}${TOOLCHAIN_NAME}${darkwhite}...\n"
			git clone --branch ${TOOLCHAIN_BRANCH} --depth ${toolchain_clone_depth} ${TOOLCHAIN_REPO} "$HOME"/${TOOLCHAIN_DIR_NAME}
			sleep ${sleep_value_after_clone}
		fi
	fi

	if [ -n "$KERNEL_REPO" ] && [ -n "$KERNEL_BRANCH" ]; then
		if [ ! -d "$HOME/$KERNEL_DIR" ]; then
			printf "\n>>> ${white}Cloning ${cyan}${KERNEL_NAME}${darkwhite}...\n"
			if [ "$RECURSIVE_KERNEL_CLONE" = 0 ]; then
				git clone --branch ${KERNEL_BRANCH} --depth ${kernel_clone_depth} ${KERNEL_REPO} "$HOME"/${KERNEL_DIR}
			else
				git clone --recursive --branch ${KERNEL_BRANCH} --depth ${kernel_clone_depth} ${KERNEL_REPO} "$HOME"/${KERNEL_DIR}
			fi
			sleep ${sleep_value_after_clone}
		fi
	fi
}

function choices() {
	if [ "$ASK_FOR_CLEAN_BUILD" = 1 ]; then
		if [ -d "$clb1" ] || [ -f "$clb2" ]; then
			printf "\n${white}Make clean build?${darkwhite}\n"
			select yn1 in "Yes" "No"; do
				case $yn1 in
					Yes )
						rm -rf "$HOME"/${KERNEL_OUT_DIR}
						if [ "$USE_CCACHE" = 1 ]; then
							rm -rf "$HOME"/.ccache/*
						fi
						cd "$HOME"/${KERNEL_DIR}
						if [ "$MAKE_CLEAN_AND_MRPROPER_IN_KERNEL_DIR_WHILE_CLEANING" = 1 ]; then
							make clean
							make mrproper
						fi
						break;;
					No ) break;;
				esac
			done
		fi
	fi

	if [ "$ASK_FOR_AK_CLEANING" = 1 ]; then
		if [ -f "$zImage1" ]; then
			printf "\n${white}Clean ${AK_DIR_NAME} folder?${darkwhite}\n"
			select yn2 in "Yes" "No"; do
				case $yn2 in
					Yes )
						find "$HOME"/${AK_DIR_NAME} -name "*$KERNEL_NAME*" -type f -exec rm -fv {} \;
						find "$HOME"/${AK_DIR_NAME} -name "zImage" -type f -exec rm -fv {} \;
						break;;
					No ) break;;
				esac
			done
		fi
	fi

	if [ -z "$CLANG_DIR_NAME" ]; then
		if [ "$ASK_FOR_COMPILATION_METHOD" = 1 ]; then
			printf "\n${white}Compilation type:${darkwhite}\n"
			select oi in "Out" "Inline/Standalone"; do
				case $oi in
					Out )
						unset out;
						break;;
					Inline/Standalone )
						unset inl;
						break;;
				esac
			done
			echo
		fi
	fi

	if [ -n "$CLANG_DIR_NAME" ]; then
		if [ "$ASK_FOR_COMPILATION_METHOD" = 1 ]; then
			printf "\n${white}${CLANG_NAME} detected, will use out compilation.${darkwhite}\n"
			echo
		fi
	fi

	if [ "$ASK_FOR_COMPILATION_METHOD" = 0 ]; then
		echo
	fi
}


function compilation() {
	start1=$SECONDS
	if [ -n "$CLANG_DIR_NAME" ]; then
		cd "$HOME"/${KERNEL_DIR}

		if [ -n "$KERNEL_BUILD_USER" ]; then
			export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
		else
			export KBUILD_BUILD_USER=$(whoami)
		fi
		if [ -n "$KERNEL_BUILD_HOST" ]; then
			export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
		else
			export KBUILD_BUILD_HOST=$(uname -n)
		fi
		export ARCH=${KERNEL_ARCH}
		export SUBARCH=${KERNEL_SUBARCH}

		make O="$HOME"/${KERNEL_OUT_DIR} \
			ARCH=${KERNEL_ARCH} \
			SUBARCH=${KERNEL_SUBARCH} \
			${KERNEL_DEFCONFIG}

		if [ "$USE_CCACHE" = 1 ]; then
			cs="ccache $HOME/${CLANG_DIR_NAME}/bin:$HOME/${TOOLCHAIN_DIR_NAME}/bin:${cs}" \
			make O="$HOME"/${KERNEL_OUT_DIR} \
			ARCH=${KERNEL_ARCH} \
			CC="$HOME"/${CLANG_DIR_NAME}/bin/${CLANG_BIN} \
			CLANG_TRIPLE=${CLANG_DIR_PREFIX} \
			CROSS_COMPILE=${TOOLCHAIN_DIR_PREFIX} \
			-j$(nproc --all)
		else
			cs="$HOME/${CLANG_DIR_NAME}/bin:$HOME/${TOOLCHAIN_DIR_NAME}/bin:${cs}" \
			make O="$HOME"/${KERNEL_OUT_DIR} \
			ARCH=${KERNEL_ARCH} \
			CC="$HOME"/${CLANG_DIR_NAME}/bin/${CLANG_BIN} \
			CLANG_TRIPLE=${CLANG_DIR_PREFIX} \
			CROSS_COMPILE=${TOOLCHAIN_DIR_PREFIX} \
			-j$(nproc --all)
		fi
	fi

	if [ "$ASK_FOR_COMPILATION_METHOD" = 0 ]; then
		cd "$HOME"/${KERNEL_DIR}

		if [ -n "$KERNEL_BUILD_USER" ]; then
			export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
		else
			export KBUILD_BUILD_USER=$(whoami)
		fi
		if [ -n "$KERNEL_BUILD_HOST" ]; then
			export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
		else
			export KBUILD_BUILD_HOST=$(uname -n)
		fi
		export ARCH=${KERNEL_ARCH}
		export SUBARCH=${KERNEL_SUBARCH}
		if [ "$USE_CCACHE" = 1 ]; then
			export CROSS_COMPILE="ccache $HOME/${TOOLCHAIN_DIR_NAME}/bin/${TOOLCHAIN_DIR_PREFIX}"
		else
			export CROSS_COMPILE="$HOME/${TOOLCHAIN_DIR_NAME}/bin/${TOOLCHAIN_DIR_PREFIX}"
		fi

		make O="$HOME"/${KERNEL_OUT_DIR} \
			ARCH=${KERNEL_ARCH} \
			SUBARCH=${KERNEL_SUBARCH} \
			${KERNEL_DEFCONFIG}

		make O="$HOME"/${KERNEL_OUT_DIR} \
			ARCH=${KERNEL_ARCH} \
			-j$(nproc --all)
	fi

	if [ "$ASK_FOR_COMPILATION_METHOD" = 1 ]; then
		if [ -z "$out" ]; then
			cd "$HOME"/${KERNEL_DIR}

			if [ -n "$KERNEL_BUILD_USER" ]; then
				export KBUILD_BUILD_USER=${KERNEL_BUILD_USER}
			else
				export KBUILD_BUILD_USER=$(whoami)
			fi
			if [ -n "$KERNEL_BUILD_HOST" ]; then
				export KBUILD_BUILD_HOST=${KERNEL_BUILD_HOST}
			else
				export KBUILD_BUILD_HOST=$(uname -n)
			fi
			export ARCH=${KERNEL_ARCH}
			export SUBARCH=${KERNEL_SUBARCH}
			if [ "$USE_CCACHE" = 1 ]; then
				export CROSS_COMPILE="ccache $HOME/${TOOLCHAIN_DIR_NAME}/bin/${TOOLCHAIN_DIR_PREFIX}"
			else
				export CROSS_COMPILE="$HOME/${TOOLCHAIN_DIR_NAME}/bin/${TOOLCHAIN_DIR_PREFIX}"
			fi

			make O="$HOME"/${KERNEL_OUT_DIR} \
				ARCH=${KERNEL_ARCH} \
				SUBARCH=${KERNEL_SUBARCH} \
				${KERNEL_DEFCONFIG}

			make O="$HOME"/${KERNEL_OUT_DIR} \
				ARCH=${KERNEL_ARCH} \
				-j$(nproc --all)
		fi
	fi

	if [ "$ASK_FOR_COMPILATION_METHOD" = 1 ]; then
		if [ -z "$inl" ]; then
			cd "$HOME"/${KERNEL_DIR}

			export ARCH=${KERNEL_ARCH}
			export SUBARCH=${KERNEL_SUBARCH}

			if [ "$USE_CCACHE" = 1 ]; then
				CROSS_COMPILE="ccache $HOME/${TOOLCHAIN_DIR_NAME}/bin/${TOOLCHAIN_DIR_PREFIX}"
			else
				CROSS_COMPILE="$HOME/${TOOLCHAIN_DIR_NAME}/bin/${TOOLCHAIN_DIR_PREFIX}"
			fi
			make ${KERNEL_DEFCONFIG}

			CROSS_COMPILE=$CROSS_COMPILE make -j$(nproc --all)
		fi
	fi
	end1=$SECONDS
}

function compilationrep() {
	if [ -n "$CLANG_DIR_NAME" ]; then
		if [ -f "$image1" ]; then
			printf "\n${green}The kernel is compiled successfully!${darkwhite}\n"
		else
			printf "\n${red}The kernel was not compiled correctly, check the log for errors.\nAborting further operations...${darkwhite}\n\n"
			kill $$
			exit 1
		fi
	fi

	if [ "$ASK_FOR_COMPILATION_METHOD" = 0 ]; then
		if [ -f "$image1" ]; then
			printf "\n${green}The kernel is compiled successfully!${darkwhite}\n"
		else
			printf "\n${red}The kernel was not compiled correctly, check the log for errors.\nAborting further operations...${darkwhite}\n\n"
			kill $$
			exit 1
		fi
	fi

	if [ -z "$out" ]; then
		if [ -f "$image1" ]; then
			printf "\n${green}The kernel is compiled successfully!${darkwhite}\n"
		else
			printf "\n${red}The kernel was not compiled correctly, check the log for errors.\nAborting further operations...${darkwhite}\n\n"
			kill $$
			exit 1
		fi
	fi

	if [ -z "$inl" ]; then
		if [ -f "$image2" ]; then
			printf "\n${green}The kernel is compiled successfully!${darkwhite}\n"
		else
			printf "\n${red}The kernel was not compiled correctly, check the log for errors.\nAborting further operations...${darkwhite}\n\n"
			kill $$
			exit 1
		fi
	fi
}

function zipbuilder() {
	kernel_ver=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')

	if [ -n "$KERNEL_NAME_FOR_AK_ZIP" ] && [ -n "$KERNEL_ANDROID_BASE_VER" ]; then
		file_name="${KERNEL_NAME_FOR_AK_ZIP}-v${kernel_ver}-${KERNEL_ANDROID_BASE_VER}-${current_date}.zip"
	elif [ -n "$KERNEL_NAME" ] && [ -n "$KERNEL_ANDROID_BASE_VER" ]; then
		file_name="${KERNEL_NAME}-v${kernel_ver}-${KERNEL_ANDROID_BASE_VER}-${current_date}.zip"
	else
		file_name="$(whoami)'s.Kernel-v${kernel_ver}-${current_date}.zip"
	fi

	if [ -n "$CLANG_DIR_NAME" ]; then
		cp "$HOME"/${KERNEL_OUT_DIR}/arch/arm64/boot/Image.gz-dtb "$HOME"/${AK_DIR_NAME}/zImage
	fi

	if [ "$ASK_FOR_COMPILATION_METHOD" = 0 ]; then
		cp "$HOME"/${KERNEL_OUT_DIR}/arch/arm64/boot/Image.gz-dtb "$HOME"/${AK_DIR_NAME}/zImage
	fi

	if [ -z "$out" ]; then
		cp "$HOME"/${KERNEL_OUT_DIR}/arch/arm64/boot/Image.gz-dtb "$HOME"/${AK_DIR_NAME}/zImage
	fi

	if [ -z "$inl" ]; then
		cp "$HOME"/${KERNEL_DIR}/arch/arm64/boot/Image.gz-dtb "$HOME"/${AK_DIR_NAME}/zImage
	fi

	printf "\n ${white}> Packing ${cyan}${KERNEL_NAME} ${kernel_ver} ${white}kernel...${darkwhite}\n\n"
	pushd "$HOME"/${AK_DIR_NAME}
		zip -r9 "${file_name}" * -x .git README.md
	popd
}

function stats() {
	size=$(ls -lah "$HOME"/${AK_DIR_NAME}/"${file_name}" | awk '{print $5}')
	echo

	if [ -n "$KERNEL_BUILD_USER" ]; then
		printf " ${white}> User: ${KERNEL_BUILD_USER}\n"
	else
		printf " ${white}> User: $(whoami)\n"
	fi

	if [ -n "$KERNEL_BUILD_HOST" ]; then
		printf " ${white}> Host: ${KERNEL_BUILD_HOST}\n"
	else
		printf " ${white}> Host: $(uname -n)\n"
	fi

	printf " ${white}> File location: $HOME/${AK_DIR_NAME}/${file_name}\n"
	printf " ${white}> File size: ${size}B\n"
	printf " ${white}> Compilation took: $((end1-start1)) seconds${darkwhite}\n"

	if [ -n "$CLANG_DIR_NAME" ]; then
		if [ "$USE_CCACHE" = 1 ]; then
			printf " ${white}> Compilation details: out-${CLANG_BIN}-ccache\n\n"
		else
			printf " ${white}> Compilation details: out-${CLANG_BIN}\n\n"
		fi
	fi

	if [ "$ASK_FOR_COMPILATION_METHOD" = 0 ]; then
		if [ "$USE_CCACHE" = 1 ]; then
			printf " ${white}> Compilation details: out-gcc-ccache\n\n"
		else
			printf " ${white}> Compilation details: out-gcc\n\n"
		fi
	fi

	if [ -z "$out" ]; then
		if [ "$USE_CCACHE" = 1 ]; then
			printf " ${white}> Compilation details: out-gcc-ccache\n\n"
		else
			printf " ${white}> Compilation details: out-gcc\n\n"
		fi
	fi

	if [ -z "$inl" ]; then
		if [ "$USE_CCACHE" = 1 ]; then
			printf " ${white}> Compilation details: standalone-gcc-ccache\n\n"
		else
			printf " ${white}> Compilation details: standalone-gcc\n\n"
		fi
	fi
		
}

variables
addvars
cloning
choices
compilation
compilationrep
if [ "$ZIP_BUILDER" = 1 ]; then
	zipbuilder
fi
if [ "$STATS" = 1 ]; then
	stats
fi
