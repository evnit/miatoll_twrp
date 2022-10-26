#!/system/bin/sh
SAVELOG=/tmp/recovery.log;
10or11() {
findAndroidversion=2;
cd /FFiles/temp/;
mkdir -p /FFiles/temp/system;
mount -r /dev/block/bootdevice/by-name/system /FFiles/temp/system;
cp /FFiles/temp/system/system/build.prop /FFiles/temp/build.prop;
umount /FFiles/temp/system;
rmdir /FFiles/temp/system;

[ ! -e /FFiles/temp/build.prop ] && { echo "/FFiles/temp/build.prop does not exist." >> $SAVELOG; return; }

if [ -n "$(grep ro.system.build.version.release=10 /FFiles/temp/build.prop)" ]; then
    findAndroidversion=1;
elif [ -n "$(grep ro.system.build.version.release=11 /FFiles/temp/build.prop)" ]; then
    findAndroidversion=2;
else
    findAndroidversion=0;
fi
if [ "$findAndroidversion" = "1" ]; then
    echo "I:TWRP: Android 10 rom. Decrypting...!" >> $SAVELOG;
    sed -i -e "s/system_ext                                              \/system_ext/#system_ext                                              \/system_ext/g" /system/etc/recovery.fstab;
elif [ "$findAndroidversion" = "2" ]; then
    echo "I:TWRP: Android 11 rom. Decrypting...!" >> $SAVELOG;
    sed -i -e "s/#system_ext                                              \/system_ext/system_ext                                              \/system_ext/g" /system/etc/recovery.fstab;
elif [ "$findAndroidversion" = "0" ]; then
    echo "I:TWRP: Not support decryption for this rom !" >> $SAVELOG;
fi

rm -r /FFiles/temp/build.prop;
}

10or11;
exit 0
