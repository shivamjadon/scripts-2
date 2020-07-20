#!/data/data/com.termux/files/usr/bin/sh
# shellcheck disable=SC2016

: <<'notice'
 *
 * Script information:
 * Personal Termux env-setup script.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

variables() {
    BIN_DIR="$HOME"/bin
    BASHRC="$HOME"/.bashrc
}

packages() {
    pkg install root-repo unstable-repo x11-repo
    pkg install tsu python wget git gnupg
    pkg update
}

setenv() {
    setenv_directories() {
        mkdir "$BIN_DIR" > /dev/null 2>&1
    }

    setenv_files() {
        touch "$BASHRC" > /dev/null 2>&1
    }

    setenv_directories;
    setenv_files;

    {
        printf 'export PATH="${PATH}:${HOME}/bin"'
        printf "\n"
    } >> "$BASHRC"
}

variables;
packages;
setenv;
