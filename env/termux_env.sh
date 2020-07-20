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
        rm -f "$BASHRC"
        touch "$BASHRC" > /dev/null 2>&1
    }

    setenv_directories;
    setenv_files;

    {
        printf 'export PATH="${PATH}:${HOME}/bin"'
        printf "\n"
    } >> "$BASHRC"

    setenv_pip() {
        pip install --upgrade pip
        pip install youtube-dl
    }

    setenv_git() {
        git config --global user.email "mscalindt@protonmail.com"
        git config --global user.name "Dimitar Yurukov"
        git config --global rerere.enabled true
        git config --global core.editor "nano"
        git config --global merge.log 5000
        git config --global credential.helper cache
        git config --global credential.helper 'cache --timeout=86400'
        git config --global core.preloadIndex true
    }

    setenv_pip;
    setenv_git;
}

variables;
packages;
setenv;
