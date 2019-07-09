#!/system/bin/sh

<<notice
 *
 * Script information:
 * During Nano kernel flash this script will insert props related to Nano in build.prop.
 * Indentation space is 4 and is space characters.
 *
 * SPDX-License-Identifier: GPL-3.0
 *
 * Copyright (C) Dimitar Yurukov <mscalindt@protonmail.com>
 *
notice

# Nano variables to insert.
# NOTE: Do NOT use space in any variable, instead use dot (.) or dash (-).

    NANO_MAINTAINER=
    NANO_DEVICE=
    NANO_RELEASE_DATE=
    NANO_VERSION=

LOG=/cache/NanoFlashLog.txt
rm -f $LOG
touch $LOG

if grep -Fq "NANO_KERNEL_PROPERTIES" /system/build.prop; then
    echo "NKP = YES" >> $LOG
    echo "==========" >> $LOG
else
    printf "\n" >> /system/build.prop
    echo "#" >> /system/build.prop
    echo "# NANO_KERNEL_PROPERTIES" >> /system/build.prop
    echo "#" >> /system/build.prop
    echo "NKP = INSERTED" >> $LOG
    echo "==============" >> $LOG
fi

if grep -Fq "nano.maintainer" /system/build.prop; then
    if grep -Fq "nano.maintainer=$NANO_MAINTAINER" /system/build.prop; then
        echo "NANO_MAINTAINER = LATEST ($NANO_MAINTAINER)" >> $LOG
    else
        nmold=$(grep nano.maintainer /system/build.prop | cut -d "=" -f2)
        nmnew=${NANO_MAINTAINER}
        sed '/nano.maintainer/d' /system/build.prop > /system/build2.prop
        rm -f /system/build.prop
        mv /system/build2.prop /system/build.prop
        echo "nano.maintainer=$NANO_MAINTAINER" >> /system/build.prop
        chmod 644 /system/build.prop
        echo "NANO_MAINTAINER = UPDATED (${nmold} to ${nmnew})" >> $LOG
    fi
else
    echo "nano.maintainer=$NANO_MAINTAINER" >> /system/build.prop
    echo "NANO_MAINTAINER = INSERTED ($NANO_MAINTAINER)" >> $LOG
fi

if grep -Fq "nano.device" /system/build.prop; then
    if grep -Fq "nano.device=$NANO_DEVICE" /system/build.prop; then
        echo "NANO_DEVICE = LATEST ($NANO_DEVICE)" >> $LOG
    else
        ndold=$(grep nano.device /system/build.prop | cut -d "=" -f2)
        ndnew=${NANO_DEVICE}
        sed '/nano.device/d' /system/build.prop > /system/build2.prop
        rm -f /system/build.prop
        mv /system/build2.prop /system/build.prop
        echo "nano.device=$NANO_DEVICE" >> /system/build.prop
        chmod 644 /system/build.prop
        echo "NANO_DEVICE = UPDATED (${ndold} to ${ndnew})" >> $LOG
    fi
else
    echo "nano.device=$NANO_DEVICE" >> /system/build.prop
    echo "NANO_DEVICE = INSERTED ($NANO_DEVICE)" >> $LOG
fi

if grep -Fq "nano.release.date" /system/build.prop; then
    if grep -Fq "nano.release.date=$NANO_RELEASE_DATE" /system/build.prop; then
        echo "NANO_RELEASE_DATE = LATEST ($NANO_RELEASE_DATE)" >> $LOG
    else
        nrdold=$(grep nano.release.date /system/build.prop | cut -d "=" -f2)
        nrdnew=${NANO_RELEASE_DATE}
        sed '/nano.release.date/d' /system/build.prop > /system/build2.prop
        rm -f /system/build.prop
        mv /system/build2.prop /system/build.prop
        echo "nano.release.date=$NANO_RELEASE_DATE" >> /system/build.prop
        chmod 644 /system/build.prop
        echo "NANO_RELEASE_DATE = UPDATED (${nrdold} to ${nrdnew})" >> $LOG
    fi
else
    echo "nano.release.date=$NANO_RELEASE_DATE" >> /system/build.prop
    echo "NANO_RELEASE_DATE = INSERTED ($NANO_RELEASE_DATE)" >> $LOG
fi

if grep -Fq "nano.version" /system/build.prop; then
    if grep -Fq "nano.version=$NANO_VERSION" /system/build.prop; then
        echo "NANO_VERSION = LATEST ($NANO_VERSION)" >> $LOG
    else
        nvold=$(grep nano.version /system/build.prop | cut -d "=" -f2)
        nvnew=${NANO_VERSION}
        sed '/nano.version/d' /system/build.prop > /system/build2.prop
        rm -f /system/build.prop
        mv /system/build2.prop /system/build.prop
        echo "nano.version=$NANO_VERSION" >> /system/build.prop
        chmod 644 /system/build.prop
        echo "NANO_VERSION = UPDATED (${nvold} to ${nvnew})" >> $LOG
    fi
else
    echo "nano.version=$NANO_VERSION" >> /system/build.prop
    echo "NANO_VERSION = INSERTED ($NANO_VERSION)" >> $LOG
fi
