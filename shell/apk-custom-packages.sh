#!/bin/bash
# ============= imm 25.12.x 仓库外的第三方插件apk ==========
# ============= 若启用 则打开注释 ========================
# ============= 但此文件也可以处理仓库内的软件去留 本质上是做了一个PACKAGES字符串的拼接 ================
#
# ---------------------------------------------------------------
# 2026-10 修订说明（七份 apk 索引 + 上游 Makefile 依赖逐条核对）
# 核对对象: https://downloads.immortalwrt.org/releases/25.12.2/
#   packages/aarch64_cortex-a53/{base,luci,packages,routing,telephony}/index.json
#   targets/mediatek/filogic/kmods/6.12.103-1-b5b7729ffbba3ecdd83f339de8fadfb8/index.json
#   targets/mediatek/filogic/packages/index.json   <-- 第 7 份：target 专属包，最容易漏查
# 合计 11397 个包名（七份索引合并去重）。
#
# 本文件只允许出现"官方源里确实存在"的包名，否则云端编译阶段会直接失败。
# 官方源里查不到的（原脚本曾启用，已注释）：
#   luci-app-quickstart / istore、luci-theme-aurora、luci-app-aurora-config、
#   luci-app-mosdns、luci-i18n-mosdns-zh-cn、luci-app-turboacc、luci-app-turboacc-mtk
#
# 【依赖闭包已核 2026-10】本文件启用的 41 个包，其 Makefile 共 53 个 DEPENDS token，全部可解析：
#   iptables / ip6tables / ip / miniupnpd 是"虚拟包"（索引里搜不到这个名字），分别由
#   iptables-nft(1.8.10-r3) / ip6tables-nft(1.8.10-r3) / ip-tiny|ip-full / miniupnpd-nftables
#   通过 PROVIDES 提供。它们**真实存在**（都在第 7 份 target 索引里，旧版笔记误判为"已移除"）。
#   因此不需要、也不应该显式写进本文件：
#     mwan3 的 "+iptables +IPV6:ip6tables"、luci-app-upnp 的 "+miniupnpd" 会自动拉入。
#   注意 ip6tables 是条件依赖：构建配置必须 CONFIG_IPV6=y 才会被拉进来，要 IPv6 多拨须确认这一项。
#   miniupnpd-nftables 则必须显式保留，否则 apk 可能在 iptables/nftables 两个变体之间任选。
#   （iptables-nft 存在不等于应该用 iptables 写规则：fw4 不走 iptables，规则仍写在 nft 里。）
#
# 想再加包之前，先自查一遍（把 <包名> 换掉）：
#   B=https://downloads.immortalwrt.org/releases/25.12.2
#   for f in packages/aarch64_cortex-a53/{base,luci,packages,routing,telephony}/index.json \
#            targets/mediatek/filogic/kmods/6.12.103-1-b5b7729ffbba3ecdd83f339de8fadfb8/index.json \
#            targets/mediatek/filogic/packages/index.json; do
#     curl -s "$B/$f"
#   done | grep -o '"<包名>":"[^"]*"'
# 能查到版本号才允许写进本文件。
# ---------------------------------------------------------------

# 各位注意 如果你构建的固件是硬路由 此文件的注释要酌情考虑是否打开 因为硬路由的闪存空间有限 若构建出来过大或者构建失败 记得调整本文件的注释
# 首页和网络向导（原脚本此包来自第三方 feed，25.12.2 官方源没有；硬开会导致编译直接失败）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-quickstart-zh-cn"
# 新增Run安装器 用于快速安装makeself打包的run文件 目前和quickfile的nginx配置冲突 请勿同时集成quickfile
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"
# 新增非常好用的文件管理器 by github sbwml
CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash quickfile luci-app-quickfile luci-i18n-quickfile-zh-cn"
# 极光主题和配置 by github eamonxg（第三方 feed，25.12.2 官方源无 luci-theme-aurora，需自建 feed 才能用）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"
# 分区扩容 by sirpdboy 
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"
# 流量监控 by timsaya
CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix luci-app-bandix luci-i18n-bandix-zh-cn"
# 新增ssrp apk
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy kmod-nft-socket xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
# 新增passwall2 apk
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall2 luci-i18n-passwall2-zh-cn"
# IPTV 流媒体转发服务器 - rtp2httpd by stackia（25.12.2 官方 luci feed 已有，可放心启用）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn"
# 新增 clashoo by kenzok8 注意若集成clashoo 则不能集成nikki 目前它们俩配置冲突
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn"
# 新增 Lucky大吉 by gdy666 & sirpdboy 
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-lucky lucky luci-i18n-lucky-zh-cn"
# daed 升级到1.28.0
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-daed-zh-cn"
# 任务设置 by sirpdboy
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-taskplan luci-i18n-taskplan-zh-cn"

# MosDNS —— 关键修正：
# 因此这里只装内核，配置走 /etc/mosdns/config.yaml（见 docs/02-DNS架构-MosDNS分流+ADG去广告.md）。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES mosdns luci-app-mosdns luci-i18n-mosdns-zh-cn"

# 仓库内代理相关apk
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nikki-zh-cn"
#luci-app-openvpn-server 配置文件存在bug 因此请勿集成 避免报错 但你可以集成luci-i18n-openvpn-zh-cn
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-openvpn-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dae-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-homeproxy-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria luci-i18n-passwall-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash luci-compat kmod-tun kmod-inet-diag kmod-nft-tproxy bash curl ip-full unzip"
# VPN
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-proto-wireguard"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-tailscale-community luci-i18n-tailscale-community-zh-cn"
# 内网穿透
CUSTOM_PACKAGES="$CUSTOM_PACKAGES zerotier luci-app-zerotier luci-i18n-zerotier-zh-cn luci-compat"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-frpc-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-frps-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ddns-go-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ddns-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ngrokc-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nps-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-xfrpc-zh-cn"
# 网盘聚合
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-openlist-zh-cn"
# 文件管理
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-go-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filebrowser-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filemanager-zh-cn"
# 网络唤醒
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-wol luci-i18n-wol-zh-cn etherwake"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-timewol-zh-cn"
# 自定义命令
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-commands-zh-cn"

# ============= 红米AX6000 (MT7986) 自定义需求（从 24.10.6 迁移） =============

# OpenClash（24.10 → nftables 专用）
#经考虑在直接在PC上运行收益比较高
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash -dnsmasq dnsmasq-full bash curl ca-bundle ip-full ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base"

# ZeroTier（保留，注意 24.10 运行时兼容性）
# 已在上面“内网穿透”区域启用：zerotier luci-app-zerotier luci-i18n-zerotier-zh-cn

# Syncdial + mwan3（25.12.2 全部在官方源，且 kmod-macvlan 在 filogic kmods 索引中存在）
# luci-app-syncdial 2.0-r25 / luci-app-mwan3 26.236.50544~cb5d434 / kmod-macvlan 6.12.103-r1
# 注意：syncdial 生成的 vwan* 在 mwan3 里被写死 family=ipv4，IPv6 需要按 docs/03 手工补
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-syncdial kmod-macvlan luci-app-mwan3 luci-i18n-mwan3-zh-cn"
# 如果只准备先验证 MWAN3 包解析，可选下面的单独测试项（非必需）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mwan3 luci-i18n-mwan3-zh-cn"

# MWAN3 的兼容层 —— 不需要显式写（订正：这两个包其实存在，之前笔记误判）：
# iptables-nft / ip6tables-nft = 1.8.10-r3，在 target 专属索引里，
# 由 mwan3 的 "+iptables +IPV6:ip6tables" 依赖自动拉入镜像（条件：CONFIG_IPV6=y）。
# 但 mwan3 2.12 的规则全部走 nftables，装它们只是为了满足依赖，不要拿 iptables 写转发规则。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES iptables-nft ip6tables-nft"

# BBR（保留，25.12 建议显式带上 fq 调度器）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-tcp-bbr kmod-sched"

# Turbo ACC + Full Cone
# 重要：ImmortalWrt 23.05+ 因 nftables 替换 iptables，原版 luci-app-turboacc 已不可用。
# 25.12.2 官方源没有 luci-app-turboacc / luci-app-turboacc-mtk（这两个一直是 lean 等第三方 feed 的包）。
# Full Cone 在 25.12.2 的真实实现是内核 nft 表达式 kmod-nft-fullcone（索引版本 6.12.103.2023.05.17~07d93b62-r3），
# 但它只在 nft 规则里手写生效，LuCI 没有开关；开启方式见 docs/04-加速-BBR-FullCone-offload.md。
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-turboacc kmod-nft-fullcone"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-turboacc-mtk"


# 原生软件流量分载：先于多拨、代理、策略路由测试；不等于启用硬件加速
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-offload kmod-nft-fullcone"

# SmartDNS —— 建议注释掉，避免与 OpenClash 的 DNS 控制冲突
# CUSTOM_PACKAGES="$CUSTOM_PACKAGES smartdns luci-app-smartdns luci-i18n-smartdns-zh-cn"

# ===== 轻量局域网管理：IP/MAC 绑定 + 网络唤醒 + 高级重启 =====
# U-Boot Mod 下不要盲目使用高级重启的分区切换功能
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-advanced-reboot luci-i18n-advanced-reboot-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-arpbind luci-i18n-arpbind-zh-cn"
# wol 已在上面“网络唤醒”区域统一启用

# 诊断插件（可选）：不会增加物理带宽，但有助于定位低于 500Mbps 的问题
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-nlbwmon luci-i18n-nlbwmon-zh-cn"
# 如果后续对照证实为缓冲膨胀问题，可考虑 SQM，但不要和 HW Flow Offload 同时启用
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-sqm luci-i18n-sqm-zh-cn"

# KMS 服务器（vlmcsd）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES vlmcsd luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn luci-lua-runtime"

# ============= AdGuard Home 去广告 / DNS 过滤 =============
# 核心 + LuCI 界面（25.12.2 官方源：adguardhome 0.107.76-r1 / luci-app-adguardhome 26.236.50544~cb5d434）
# 依赖说明：luci-app-adguardhome 要求 adguardhome >= 0.107.73-r3，官方索引正好满足；
# libcares 等动态库由 apk 自动依赖解析，无需手工写死（写死反而在换源时容易失败）。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES adguardhome luci-app-adguardhome"

# ============= 推荐补充（社区好评 / 实用，全部在 25.12.2 官方源内） =============
# UPnP/NAT-PMP：BT/游戏联机必需；nftables 版后端用 miniupnpd-nftables（不要装 iptables 版）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-upnp miniupnpd-nftables"
# 中断均衡：MT7986 四核，万兆/多拨场景下能摊平软中断
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-irqbalance irqbalance"
# 终端：不装 ssh 也能在网页里排障，配合 docs 里的验证命令最省事
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-ttyd luci-i18n-ttyd-zh-cn"
# 系统监控：CPU/温度/流量曲线，定位掉速时看 CPU 是否打满
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-statistics luci-i18n-statistics-zh-cn"
# 在线升级（保留配置）；25.12 用 apk 后端，attendedsysupgrade 已适配
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-attendedsysupgrade luci-i18n-attendedsysupgrade-zh-cn"
# 以下三项按需打开：
# banip（基于 nftables 的 IP 黑名单，可订阅恶意 IP 表，注意 RAM）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-banip banip"
# pbr（策略路由，nft 版；比 mwan3 规则更适合"按域名/网段走指定 WAN"）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-pbr"
# DDNS（IPv4+IPv6 双栈更新）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-ddns luci-i18n-ddns-zh-cn"
# 无线：多 AP 无缝漫游
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-dawn luci-i18n-dawn-zh-cn"
# 无线：定时开关 Wi-Fi
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-wifischedule"
# 代理类（打开前先确认订阅协议；25.12 官方源内为 luci-app-passwall / luci-app-homeproxy / luci-app-openclash）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core sing-box hysteria geoview kmod-nft-tproxy kmod-nft-socket luci-app-passwall"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-homeproxy kmod-tun kmod-inet-diag"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash luci-compat bash curl ca-bundle unzip"

#===========================以下imm仓库内的软件==============================↓
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-3cat-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-3ginfo-lite-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-acl-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-acme-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-adblock-fast-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-adblock-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-advanced-reboot-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-airplay2-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-amule-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-appfilter-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-aria2-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-arpbind-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-attendedsysupgrade-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-autoreboot-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-banip-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-battstatus-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-bcp38-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-bitsrunlogin-go-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-bmx7-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-cd8021x-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-cifs-mount-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-clamav-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-cloudflared-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-coovachilli-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-cpulimit-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-crowdsec-firewall-bouncer-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-cshark-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dashboard-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dawn-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dcwapd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-diskman-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dsl-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dump1090-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dynapoint-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-email-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-eoip-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-eqos-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-example-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-fwknopd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-gost-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-haproxy-tcp-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-hd-idle-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-https-dns-proxy-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ipsec-vpnd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-irqbalance-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-keepalived-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ksmbd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-lldpd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-lxc-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-microsocks-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-minidlna-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-minieap-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mjpg-streamer-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-modemband-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mosquitto-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-msd_lite-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-music-remote-center-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-n2n-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-natmap-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-netdata-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nextdns-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nfs-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nft-qos-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nlbwmon-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nut-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ocserv-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-oled-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-olsr-services-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-olsr-viz-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-olsr-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-omcproxy-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-openwisp-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-oscam-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-p910nd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-pagekitec-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-pbr-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-pppoe-relay-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-pppoe-server-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-privoxy-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ps3netsrv-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-qbittorrent-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-qos-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-radicale-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ramfree-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-rclone-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-rp-pppoe-server-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-rustdesk-server-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-samba4-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ser2net-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-smartdns-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-sms-tool-js-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-snmpd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-softethervpn-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-splash-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-spotifyd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-sqm-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-squid-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-sshtunnel-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-statistics-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-syncthing-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-sysuh3c-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-tinyproxy-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-tor-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-transmission-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-travelmate-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ttyd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ua2f-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-udpxy-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-uhttpd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-unbound-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-upnp-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-usb-printer-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-usteer-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-v2raya-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-vlmcsd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-vnstat2-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-vsftpd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-watchcat-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-wechatpush-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-wifischedule-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-xinetd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-xlnetacc-zh-cn"
