#!/bin/bash

function fetch_rtl8812au_driver() {

    if [[ ! "$(ls -A rtl8812au)" ]]; then    
        echo "Download the rtl8812au driver"
        git clone ${RTL_8812AU_REPO}
    fi

    pushd rtl8812au
        git fetch
        git reset --hard
        git checkout ${RTL_8812AU_BRANCH}
        git pull
   
        if [[ "${PLATFORM}" == "pi" ]]; then
            sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/' Makefile
            sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/' Makefile
        fi

	if [[ "${PLATFORM}" == "jetson" ]]; then
	    sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
	    sed -i 's/CONFIG_PLATFORM_ARM64_RPI = n/CONFIG_PLATFORM_ARM64_RPI = y/g' Makefile
	    echo "jetsonSBC"
        fi
	

        pushd core
            # Change the STBC value to make all antennas send with awus036ACH
            sed -i 's/u8 fixed_rate = MGN_1M, sgi = 0, bwidth = 0, ldpc = 0, stbc = 0;/u8 fixed_rate = MGN_1M, sgi = 0, bwidth = 0, ldpc = 0, stbc = 1;/' rtw_xmit.c
        popd

    popd
}

function build_rtl8812au_driver() {
    pushd rtl8812au
        make clean
	
	if [[ "${PLATFORM}" == "pi" ]]; then
         make KSRC=${LINUX_DIR} -j $J_CORES M=$(pwd) modules || exit 1
	 mkdir -p ${PACKAGE_DIR}/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl8812au
         install -p -m 644 88XXau.ko "${PACKAGE_DIR}/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl8812au/" || exit 1
    
        fi
	
	if [[ "${PLATFORM}" == "jetson" ]]; then
		export KERNEL_VERSION="4.9.253OpenHD-2.1-tegra"
		export CROSS_COMPILE=$Tools/gcc-arm-11.2-2022.02-x86_64-aarch64_be-none-linux-gnu/bin/aarch64_be-none-linux-gnu-
	        make KSRC=${LINUX_DIR}/build -j $J_CORES M=$(pwd) modules || exit 1
		mkdir -p ${PACKAGE_DIR}/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl8812au
         	install -p -m 644 88XXau.ko "${PACKAGE_DIR}/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl8812au/" || exit 1
	fi


       popd
}

# ========================================================== #

function fetch_rtl8812bu_driver() {

    if [[ ! "$(ls -A rtl88x2bu)" ]]; then    
        echo "Download the rtl8812bu driver"
        git clone ${RTL_8812BU_REPO}
    fi

    pushd rtl88x2bu
        git fetch
        git reset --hard
        git checkout ${RTL_8812BU_BRANCH}
        git pull

        if [[ "${PLATFORM}" == "pi" ]]; then
            sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/' Makefile
            sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/' Makefile
        fi

        sed -i 's/CONFIG_WIFI_MONITOR = n/CONFIG_WIFI_MONITOR = y\nCONFIG_AP_MODE = y/' Makefile

        sed -i 's/export TopDIR ?= $(shell pwd)/export TopDIR2 ?= $(shell pwd)/' Makefile
        sed -i '/export TopDIR2 ?= $(shell pwd)/a export TopDIR := $(TopDIR2)/drivers/net/wireless/realtek/rtl88x2bu/' Makefile
    popd
}

function build_rtl8812bu_driver() {
    pushd rtl88x2bu
        make clean
		if [[ "${PLATFORM}" == "jetson" ]]; then
		export KERNEL_VERSION="4.9.253OpenHD-2.1-tegra"
		export CROSS_COMPILE=$Tools/gcc-arm-11.2-2022.02-x86_64-aarch64_be-none-linux-gnu/bin/aarch64_be-none-linux-gnu-
		make KSRC=$SRC_DIR/workdir/headers/linux-headers-4.9.253-tegra-linux_x86_64/kernel-4.9 -j $J_CORES M=$(pwd) modules || exit 1
		else
        	make KSRC=${LINUX_DIR} -j $J_CORES M=$(pwd) modules || exit 1
	        fi

        mkdir -p ${PACKAGE_DIR}/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl88x2bu
        install -p -m 644 88x2bu.ko "${PACKAGE_DIR}/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl88x2bu/" || exit 1
    popd
}


# ========================================================== #

function fetch_rtl8188eus_driver() {

    if [[ ! "$(ls -A rtl8188eus)" ]]; then    
        echo "Download the rtl8188eus driver"
        git clone ${RTL_8188EUS_REPO}
    fi

    pushd rtl8188eus
        git fetch
        git reset --hard
        git checkout ${RTL_8188EUS_BRANCH}
        git pull

        if [[ "${PLATFORM}" == "pi" ]]; then
            sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/' Makefile
            sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/' Makefile
        fi
    popd
}

function build_rtl8188eus_driver() {
    pushd rtl8188eus
        make clean
	if [[ "${PLATFORM}" == "jetson" ]]; then
		export KERNEL_VERSION="4.9.253OpenHD-2.1-tegra"
		export CROSS_COMPILE=$Tools/gcc-arm-11.2-2022.02-x86_64-aarch64_be-none-linux-gnu/bin/aarch64_be-none-linux-gnu-
		make KSRC=$SRC_DIR/workdir/headers/linux-headers-4.9.253-tegra-linux_x86_64/kernel-4.9 -j $J_CORES M=$(pwd) modules || exit 1
		else
        	make KSRC=${LINUX_DIR} -j $J_CORES M=$(pwd) modules || exit 1
		fi 
        mkdir -p ${PACKAGE_DIR}/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl8188eus
        install -p -m 644 8188eu.ko "${PACKAGE_DIR}/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl8188eus/" || exit 1
    popd
}
