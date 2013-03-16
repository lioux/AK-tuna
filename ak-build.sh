#!/bin/bash

clear

#
# VAR
#
PARAM=$1
DATE_START=$(date +"%s")
CWM_MOVE="/home/anarkia/Scrivania/"

if [ "${PARAM}" == "debug" ]; then
 echo ""; echo "# AK BUILD DEBUG ------------------------------------------------------------------------------------------------"; echo ""
  #
  # CREATE DEFAULT CONFIG
  #
  make clean; sleep 3; make distclean; sleep 3
   echo ""
  rm -rfv .config; rm -rfv .config.old
   echo ""
  make CROSS_COMPILE=${HOME}/android/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm tuna_ak_debug_defconfig
  #make CROSS_COMPILE=${HOME}/android/AK-Kernel/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm tuna_ak_debug_defconfig
  #make CROSS_COMPILE=${HOME}/android/AK-Kernel/AK-linaro/4.7.3-2012.12.20121218/bin/arm-linux-gnueabihf- ARCH=arm tuna_ak_debug_defconfig
  #make CROSS_COMPILE=${HOME}/android/AK-linaro/4.7.3-2013.02.20130221/bin/arm-linux-gnueabihf- ARCH=arm tuna_ak_debug_defconfig
  #
  # LOCAL KERNEL VERSION
  #
  ak_ver="ak.666.debug"; export LOCALVERSION="~"`echo $ak_ver`

  debug=1

else
 echo ""; echo "# AK BUILD FULL ------------------------------------------------------------------------------------------------"; echo ""
  #
  # CREATE DEFAULT CONFIG
  #
  make clean; sleep 3; make distclean; sleep 3
   echo ""
  rm -rfv .config; rm -rfv .config.old
   echo ""
  #make CROSS_COMPILE=${HOME}/android/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm tuna_ak_defconfig
  #make CROSS_COMPILE=${HOME}/android/AK-Kernel/AK-linaro/4.7.2-2012.10-20121023/bin/arm-linux-gnueabihf- ARCH=arm tuna_ak_defconfig
  #make CROSS_COMPILE=${HOME}/android/AK-Kernel/AK-linaro/4.7.3-2012.12.20121218/bin/arm-linux-gnueabihf- ARCH=arm tuna_ak_defconfig
  make CROSS_COMPILE=${HOME}/android/AK-linaro/4.7.3-2013.02.20130221/bin/arm-linux-gnueabihf- ARCH=arm tuna_ak_defconfig
  #
  # LOCAL KERNEL VERSION
  #
  ak_ver="AK.008.CYLON"; export LOCALVERSION="~"`echo $ak_ver`

  debug=0

fi

#
# CROSS COMPILE KERNEL MODULES
#
#make CROSS_COMPILE=${HOME}/android/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm -j4 modules
#make CROSS_COMPILE=${HOME}/android/AK-Kernel/AK-linaro/4.7.2-2012.10-20121023/bin/arm-linux-gnueabihf- ARCH=arm -j4 modules
#make CROSS_COMPILE=${HOME}/android/AK-Kernel/AK-linaro/4.7.3-2012.12.20121218/bin/arm-linux-gnueabihf- ARCH=arm -j4 modules
make CROSS_COMPILE=${HOME}/android/AK-linaro/4.7.3-2013.02.20130221/bin/arm-linux-gnueabihf- ARCH=arm -j4 modules

#
# FIND .KO MODULE CREATE WITH CROSS COMPILE
# AND THEN COPY .KO MODULE TO CWM SCRIPT
#
echo ""
rm -rfv ${HOME}/android/AK-ramdisk/cwm/system/lib/modules/*
find ${HOME}/android/AK-cylon/ -name '*.ko' -exec cp -v {} ${HOME}/android/AK-ramdisk/cwm/system/lib/modules \;
#${HOME}/android/AK-linaro/4.6.x-google/bin/arm-eabi-strip --strip-debug ${HOME}/android/AK-ramdisk/cwm/system/lib/modules/*.ko
#${HOME}/android/AK-Kernel/AK-linaro/4.7.2-2012.10-20121023/bin/arm-linux-gnueabihf-strip --strip-debug ${HOME}/android/AK-Kernel/AK-ramdisk/cwm/system/lib/modules/*.ko
#${HOME}/android/AK-Kernel/AK-linaro/4.7.3-2012.12.20121218/bin/arm-linux-gnueabihf-strip --strip-debug ${HOME}/android/AK-Kernel/AK-ramdisk/cwm/system/lib/modules/*.ko
${HOME}/android/AK-linaro/4.7.3-2013.02.20130221/bin/arm-linux-gnueabihf-strip --strip-debug ${HOME}/android/AK-ramdisk/cwm/system/lib/modules/*.ko
echo ""

#
# CROSS COMPILE KERNEL WITH TOOLCHAIN
#
#make CROSS_COMPILE=${HOME}/android/AK-linaro/4.6.x-google/bin/arm-eabi- ARCH=arm -j4 zImage
#make CROSS_COMPILE=${HOME}/android/AK-Kernel/AK-linaro/4.7.2-2012.10-20121023/bin/arm-linux-gnueabihf- ARCH=arm -j4 zImage
#make CROSS_COMPILE=${HOME}/android/AK-Kernel/AK-linaro/4.7.3-2012.12.20121218/bin/arm-linux-gnueabihf- ARCH=arm -j4 zImage
make CROSS_COMPILE=${HOME}/android/AK-linaro/4.7.3-2013.02.20130221/bin/arm-linux-gnueabihf- ARCH=arm -j4 zImage

#
# COPY ZIMAGE OF KERNEL
# FOR MERGE WITH RAMDISK
#
cp -vr arch/arm/boot/zImage ../AK-ramdisk/
cd ../AK-ramdisk/ramdisk-4.2.2/
chmod 750 init* charger
chmod 644 default.prop
chmod 640 fstab.tuna
chmod 644 ueventd*
cd ..
./repack-bootimg.pl zImage ramdisk-4.2.2/ boot.img
cp -vr boot.img cwm/

#
# CREATE A CWM PKG
# FOR FLASH FROM RECOVERY
#
cd cwm
zip -r `echo $ak_ver`.zip *
rm -rf $CWM_MOVE/`echo $ak_ver`.zip
cp -vr `echo $ak_ver`.zip $CWM_MOVE/AK-Kernel/
if [ ! -d ../zip ]; then
 mkdir ../zip
fi
mv `echo $ak_ver`.zip ../zip/
rm -rf `echo $ak_ver`.zip boot.img
cd ..
cd ../AK-cylon/

echo .
echo ..
echo ... Compile Complite ! ... `echo $ak_ver`.zip
echo ..
echo .

#
# PRINT BUILDING COMPILE-TIME
#
echo ""
DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo ""
