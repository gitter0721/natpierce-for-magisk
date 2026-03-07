#!/system/bin/sh

MODDIR=${0%/*}


# 等待系统启动
sleep 5

# 启动服务
$MODDIR/scripts/start.sh

echo "[$(date "+%Y-%m-%d %H:%M:%S")] 服务启动完成" >> $MODDIR/logs/module.txt

# 监听模块开关
inotifyd $MODDIR/scripts/watch.sh /data/adb/modules/natpierce &
echo "[$(date "+%Y-%m-%d %H:%M:%S")] 监听..." >> $MODDIR/logs/module.txt