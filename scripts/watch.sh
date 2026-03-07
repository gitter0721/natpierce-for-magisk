#!/system/bin/sh

EVENT=$1
DIR=$2
FILE=$3

MODDIR=${DIR}

if [ "$FILE" = "disable" ]; then

    if [ "$EVENT" = "n" ]; then
        # 模块关闭
        $MODDIR/scripts/stop.sh
    fi

    if [ "$EVENT" = "d" ]; then
        # 模块开启
        $MODDIR/scripts/start.sh
    fi

fi