natpierce for magisk

一个用于在 Android 上运行 皎月连 (natpierce) 的 Magisk 模块，支持开机自动启动、模块开关控制服务、虚拟组网以及局域网访问。

该模块可以让获取了root的Android 设备作为服务端使用。

皎月连官网:https://www.natpierce.cn/

测试环境安卓16 设备一加pad2pro 已测试内容:点对网可用

！注意:不能与其他vpn共存，开启其他vpn后，皎月连会停止服务。需要先关闭vpn再到magisk中重新开关一下进行重启！

安装

1.下载模块 ZIP

2.打开 Magisk

3.进入模块

4.点击从本地安装

5.选择natpierce.zip

6.重启设备生效


使用

安装模块后：

开机自动启动服务

Magisk 开启模块 → 启动 natpierce

Magisk 关闭模块 → 停止 natpierce

无需手动运行任何脚本。


日志

日志文件位置：

/data/adb/modules/natpierce/logs/

主要日志：
natpierce.log
module.txt
大小超过1MB自动清理

配置文件位置:/data/adb/modules/natpierce/system/bin/data/config

可以保存配置文件便于以后跳过繁琐的登录以及配置过程ovo

免责声明
本项目仅用于学习和研究用途，请遵守当地法律法规。
