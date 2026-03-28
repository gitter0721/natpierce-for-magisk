#!/system/bin/sh
# 清理防火墙规则
    iptables -D INPUT -i natpierce -j ACCEPT 2>/dev/null
    iptables -D FORWARD -i natpierce -j ACCEPT 2>/dev/null
    iptables -D FORWARD -o natpierce -j ACCEPT 2>/dev/null

    # 清理路由规则
    ip rule del pref 1000 lookup main 2>/dev/null