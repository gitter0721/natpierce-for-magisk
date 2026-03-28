#!/system/bin/sh

# ================= 1. 等待系统完全启动 =================
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# 防止系统深度休眠断网
dumpsys deviceidle disable
echo "prevent_deep_sleep_forever" > /sys/power/wake_lock

# ================= 2. 环境变量初始化 =================
MODDIR=${0%/*}
LOG_DIR="$MODDIR/logs"
LOG_FILE="$LOG_DIR/run.log"
BIN_PATH="$MODDIR/system/bin/natpierce"
PROP_FILE="$MODDIR/module.prop"
MAX_SIZE=1048576

# 创建日志目录
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

# 动态获取 module.prop 中的基础描述
BASE_DESC=$(grep '^description=' "$PROP_FILE" | sed -e 's/^description=//' -e 's/ ｜ 当前状态:.*//')
if [ -z "$BASE_DESC" ]; then
    BASE_DESC="natpierce 皎月连 内网穿透模块"
fi

# ================= 3. 核心功能函数 =================
log() {
    CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$CURRENT_TIME] $1" >> "$LOG_FILE"
}

LAST_STATE=""
update_status() {
    local current_state="$1"
    # 只有状态发生变化时才写入
    if [ "$LAST_STATE" != "$current_state" ]; then
        sed -i "s|^description=.*|description=${BASE_DESC} ｜ 当前状态: ${current_state}|g" "$PROP_FILE"
        LAST_STATE="$current_state"
    fi
}

start_natpierce() {
    log "准备启动 natpierce 并配置网络规则..."
    
    # 确保 tun 设备存在
    if [ ! -e /dev/net/tun ]; then
        mkdir -p /dev/net
        mknod /dev/net/tun c 10 200
        chmod 666 /dev/net/tun
    fi

    # 启动进程
    nohup "$BIN_PATH" -S -p 33272 >> "$LOG_FILE" 2>&1 &
    
    # ================= 防火墙规则 =================
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT

    iptables -D INPUT -i natpierce -j ACCEPT 2>/dev/null
    iptables -I INPUT 1 -i natpierce -j ACCEPT

    iptables -D FORWARD -i natpierce -j ACCEPT 2>/dev/null
    iptables -I FORWARD 1 -i natpierce -j ACCEPT

    iptables -D FORWARD -o natpierce -j ACCEPT 2>/dev/null
    iptables -I FORWARD 1 -o natpierce -j ACCEPT

    # 开启转发与关闭 rp_filter
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
    echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter

    # ================= 修复路由 =================
    ip rule del pref 1000 lookup main 2>/dev/null
    ip rule add pref 1000 lookup main

    log "natpierce 启动且网络规则配置完成"
}

stop_natpierce() {
    log "清理 natpierce 进程及网络规则..."
    
    # 强制杀掉进程
    PID=$(pidof natpierce)
    if [ -n "$PID" ]; then
        kill -9 $PID
    fi
    pkill natpierce

    # 清理防火墙规则
    iptables -D INPUT -i natpierce -j ACCEPT 2>/dev/null
    iptables -D FORWARD -i natpierce -j ACCEPT 2>/dev/null
    iptables -D FORWARD -o natpierce -j ACCEPT 2>/dev/null

    # 清理路由规则
    ip rule del pref 1000 lookup main 2>/dev/null

    log "natpierce 已停止，规则已彻底清理"
}

log "---------- 模块服务初始化启动 ----------"

# ================= 4. 主守护循环 =================
while true; do
    # 判断模块是否被禁用
    if [ -f "$MODDIR/disable" ] || [ -f "$MODDIR/remove" ]; then
        PID=$(pidof natpierce)
        if [ -n "$PID" ]; then
            log "已检测到面具开关关闭，准备停止服务 (PID: $PID)"
            stop_natpierce
        fi
        update_status "🔴已停止"
    else
        # 模块处于开启状态，查找进程是否在运行
        PID=$(pidof natpierce)
        if [ -z "$PID" ]; then
            # 没有运行，尝试启动
            update_status "🟡正在拉起..."
            
            # 崩溃拉起前先执行一次 stop
            stop_natpierce
            sleep 2
            
            start_natpierce
            sleep 3
            
            # 二次确认
            PID=$(pidof natpierce)
            if [ -n "$PID" ]; then
                update_status "🟢运行中 (PID: $PID)"
            fi
        else
            # 正常运行中，抓取 PID 并更新状态
            update_status "🟢运行中 (PID: $PID)"
        fi
    fi
    
    # ================= 日志滚动清理 =================
    if [ -f "$LOG_FILE" ]; then
        FILE_SIZE=$(stat -c%s "$LOG_FILE")
        if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
            # 清空文件内容但保留文件本身
            : > "$LOG_FILE"
            log "日志体积超过1MB，已执行自动清空。"
        fi
    fi
    
    # 轮询间隔
    sleep 6
done