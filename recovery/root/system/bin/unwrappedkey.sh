#!/system/bin/sh
SAVELOG=/tmp/recovery.log;
findwrappedkeyfbevx_decryption() {
nowrappedfbevx=0;
cd /FFiles/temp/;
mkdir -p /FFiles/temp/vendor;
mount -r /dev/block/bootdevice/by-name/vendor /FFiles/temp/vendor;
cp /FFiles/temp/vendor/etc/fstab.qcom /FFiles/temp/fstab.prop;
umount /FFiles/temp/vendor;
rmdir /FFiles/temp/vendor;

mkdir -p /FFiles/temp/system;
mount -r /dev/block/bootdevice/by-name/system /FFiles/temp/system;
cp /FFiles/temp/system/system/build.prop /FFiles/temp/build.prop;
umount /FFiles/temp/system;
rmdir /FFiles/temp/system;

[ ! -e /FFiles/temp/fstab.prop ] && { echo "/FFiles/temp/fstab.prop does not exist." >> $SAVELOG; return; }
[ ! -e /FFiles/temp/build.prop ] && { echo "/FFiles/temp/build.prop does not exist." >> $SAVELOG; return; }

if [ -n "$(grep ro.potato /FFiles/temp/build.prop)" ]; then romnosupport=1;
elif [ -n "$(grep org.pixelplusui /FFiles/temp/build.prop)" ]; then romnosupport=1;
elif [ -n "$(grep org.evolution /FFiles/temp/build.prop)" ]; then romnosupport=1;
elif [ -n "$(grep ro.pixys /FFiles/temp/build.prop)" ]; then romnosupport=1;
elif [ -n "$(grep ro.streak /FFiles/temp/build.prop)" ]; then romnosupport=1;
fi

if [ -n "$(grep fileencryption=ice /FFiles/temp/fstab.prop)" ]; then
    echo "I:TWRP: FBEv1 rom...." >> $SAVELOG;
    sed -i -e "s/fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0,metadata_encryption=aes-256-xts:wrappedkey_v0,keydirectory=\/metadata\/vold\/metadata_encryption,quota,reservedsize=128M,sysfs_path=\/sys\/devices\/platform\/soc\/1d84000.ufshc,checkpoint=fs/fileencryption=ice,keydirectory=\/metadata\/vold\/metadata_encryption,wrappedkey,quota,reservedsize=128M,checkpoint=fs/g" /system/etc/recovery.fstab;
    if [ -n "$(grep ,wrappedkey, /FFiles/temp/fstab.prop)" ]; then
        nowrappedfbevx=0;
    else
        nowrappedfbevx=1;
    fi

    if [ "$nowrappedfbevx" = "1" ]; then
        echo "I:TWRP: FBEv1 UnWrappedkey rom. Decrypting...!" >> $SAVELOG;
        sed -i -e "s/,wrappedkey,/,/g" /system/etc/recovery.fstab;
        sed -i -e "s/;wrappedkey//g" /system/etc/twrp.flags;
    elif [ "$nowrappedfbevx" = "0" ]; then
            if [ "$romnosupport" = "1" ]; then
                echo "I:TWRP: FBEv1 UnWrappedkey rom. Decrypting...!" >> $SAVELOG;
                sed -i -e "s/,wrappedkey,/,/g" /system/etc/recovery.fstab;
                sed -i -e "s/;wrappedkey//g" /system/etc/twrp.flags;
            else
                echo "I:TWRP: FBEv1 Wrappedkey rom. Decrypting...!" >> $SAVELOG;
            fi
    fi

elif [ -n "$(grep fileencryption=aes /FFiles/temp/fstab.prop)" ]; then # to FBEv2
    echo "I:TWRP: FBEv2 rom...." >> $SAVELOG;
    sed -i -e "s/fileencryption=ice,keydirectory=\/metadata\/vold\/metadata_encryption,wrappedkey,quota,reservedsize=128M,checkpoint=fs/fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0,metadata_encryption=aes-256-xts:wrappedkey_v0,keydirectory=\/metadata\/vold\/metadata_encryption,quota,reservedsize=128M,sysfs_path=\/sys\/devices\/platform\/soc\/1d84000.ufshc,checkpoint=fs/g" /system/etc/recovery.fstab;
    if [ -n "$(grep wrappedkey_v0 /FFiles/temp/fstab.prop)" ]; then
        nowrappedfbevx=0;
    else
        nowrappedfbevx=1;
    fi

    if [ "$nowrappedfbevx" = "1" ]; then
        echo "I:TWRP: FBEv2 UnWrappedkey rom. Decrypting...!" >> $SAVELOG;
        sed -i -e "s/+wrappedkey_v0//g" /system/etc/recovery.fstab;
        sed -i -e "s/:wrappedkey_v0//g" /system/etc/recovery.fstab;
        sed -i -e "s/,wrappedkey,/,/g" /system/etc/recovery.fstab;
    elif [ "$nowrappedfbevx" = "0" ]; then
            if [ "$romnosupport" = "1" ]; then
                echo "I:TWRP: FBEv2 UnWrappedkey rom. Decrypting...!" >> $SAVELOG;
                sed -i -e "s/+wrappedkey_v0//g" /system/etc/recovery.fstab;
                sed -i -e "s/:wrappedkey_v0//g" /system/etc/recovery.fstab;
                sed -i -e "s/,wrappedkey,/,/g" /system/etc/recovery.fstab;
            else
                echo "I:TWRP: FBEv2 Wrappedkey rom. Decrypting...!" >> $SAVELOG;
            fi
    fi
fi #else
rm -r /FFiles/temp/fstab.prop;
rm -r /FFiles/temp/build.prop;
}

findwrappedkeyfbevx_decryption;
exit 0;
