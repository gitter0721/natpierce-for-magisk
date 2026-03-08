#!/system/bin/sh

MODDIR=${0%/*}


# 循环等待系统完全启动
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 3
done

dumpsys deviceidle disable

echo "prevent_deep_sleep_forever" > /sys/power/wake_lock

# 启动服务
$MODDIR/scripts/start.sh

echo "[$(date "+%Y-%m-%d %H:%M:%S")] 服务启动完成" >> $MODDIR/logs/module.txt

# 监听模块开关
inotifyd $MODDIR/scripts/watch.sh /data/adb/modules/natpierce &
echo "[$(date "+%Y-%m-%d %H:%M:%S")] 监听..." >> $MODDIR/logs/module.txt