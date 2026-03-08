#!/system/bin/sh

MODDIR=${0%/*}/..
LOG_FILE=$MODDIR/logs/module.txt
MAX_SIZE=1048576
sleep 10

# 确保 tun 存在
if [ ! -e /dev/net/tun ]; then
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 666 /dev/net/tun
fi


# 启动 natpierce
$MODDIR/system/bin/natpierce -S -p 33272 \
    > $MODDIR/logs/natpierce.log 2>&1 &

# 防火墙
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -I INPUT 1 -i natpierce -j ACCEPT
iptables -I FORWARD 1 -i natpierce -j ACCEPT
iptables -I FORWARD 1 -o natpierce -j ACCEPT

# 开启转发
echo 1 > /proc/sys/net/ipv4/ip_forward

# 关闭 rp_filter
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter


# 修复 Android policy routing
ip rule add pref 1000 lookup main 2>/dev/null


# 检查文件是否存在
if [ -f "$LOG_FILE" ]; then
    # 获取文件当前大小 
    FILE_SIZE=$(stat -c%s "$LOG_FILE")

    # 判断是否超过设定大小
    if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
        # 清空文件内容，但保留文件
        : > "$LOG_FILE"
        
        # 记录一次清理日志的操作（可选）
        echo "[$(date "+%Y-%m-%d %H:%M:%S")] 日志超过1MB，已执行自动清空。" > "$LOG_FILE"
    fi
fi

echo "[$(date "+%Y-%m-%d %H:%M:%S")] natpierce已启动" >> $MODDIR/logs/module.txt