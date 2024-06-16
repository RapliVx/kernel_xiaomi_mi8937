#!/bin/bash
# Compile script for Arisuu kernel
# Copyright (c) RapliVx Aka Rafi Aditya

# Setup
export KBUILD_BUILD_USER=Rapli
export KBUILD_BUILD_HOST=Projects-Anime
DEVICE="Ulysse"
CLANG="Proton Clang"
SECONDS=0
TC_DIR="/workspace/kernel_xiaomi_mi8937/toolchain"
AK3_DIR="/workspace/kernel_xiaomi_surya/Android/AK3"
DEFCONFIG="nexus_defconfig"

# Header
cyan="\033[96m"
green="\033[92m"
red="\033[91m"
blue="\033[94m"
yellow="\033[93m"

echo -e "$cyan===========================\033[0m"
echo -e "$cyan= START COMPILING KERNEL  =\033[0m"
echo -e "$cyan===========================\033[0m"

echo -e "$blue...KSABAR...\033[0m"

echo -e -ne "$green== (10%)\r"
sleep 0.7
echo -e -ne "$green=====                     (33%)\r"
sleep 0.7
echo -e -ne "$green=============             (66%)\r"
sleep 0.7
echo -e -ne "$green=======================   (100%)\r"
echo -ne "\n"

echo -e -n "$yellow\033[104mPRESS ENTER TO CONTINUE\033[0m"
read P
echo  $P

# Version Kernel
echo -e " "
read -rp "[?] Insert kernel version: " VERSION
echo -e " "

# Build Script

function clean() {
    echo -e "\n"
    echo -e "$red [!] CLEANING UP \\033[0m"
    echo -e "\n"
    rm -rf out
    make mrproper
}

function build_kernel() {
export PATH="$TC_DIR/bin:$PATH"
make O=out ARCH=arm64 $DEFCONFIG
make -j$(nproc --all) O=out ARCH=arm64 \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      CC=clang \
                      LLVM=1

# Kernel Dir
kernel="out/arch/arm64/boot/Image.gz-dtb"

# ZIPNAME
ZIPNAME="ZeroTwo-Kernel-[$VERSION]-$(date '+%Y%m%d-%H%M').zip"

if [ -f "$kernel" ]; then
		echo -e "$green===============================================\033[0m"
		echo -e "$green= [+] Kernel compiled succesfully! Zipping up...\033[0m"
		echo -e "$green================================================\033[0m"
	if [ -d "$AK3_DIR" ]; then
		cp -r $AK3_DIR AnyKernel3
	elif ! git clone -q https://github.com/RapliVx/AnyKernel3.git -b ulysse; then
		echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
		exit 1
	fi
	cp $kernel AnyKernel3
	rm -rf out/arch/arm64/boot
	cd AnyKernel3
	git checkout ulysse &> /dev/null
	zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
	cd ..
	rm -rf AnyKernel3
fi

if [ -f $ZIPNAME ] ; then
    echo -e "$green===========================\033[0m"
    echo -e "$green=  SUCCESS COMPILE KERNEL \033[0m"
    echo -e "$green=  Device    : $DEVICE \033[0m"
    echo -e "$green=  Defconfig : $DEFCONFIG \033[0m"
    echo -e "$green=  Toolchain : $CLANG \033[0m"
    echo -e "$green=  Out       : $ZIPNAME \033[0m "
    echo -e "$green=  Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) \033[0m "
    echo -e "$green=  Have A Brick Day Nihahahah \033[0m"
    echo -e "$green===========================\033[0m"
else
echo -e "$red! FIX YOUR KERNEL SOURCE BRUH !?\033[0m"
fi
}

# execute
clean
build_kernel