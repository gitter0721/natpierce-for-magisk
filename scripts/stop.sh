#!/system/bin/sh
MODDIR=${0%/*}/..
pkill natpierce
echo "[$(date "+%Y-%m-%d %H:%M:%S")] 服务被用户关闭" >> $MODDIR/logs/module.txt