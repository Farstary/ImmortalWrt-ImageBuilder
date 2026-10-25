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
# 合计 11376 个包名（七份索引合并去重）。
#
# 【依赖闭包已核 2026-10】本文件启用的包，其 Makefile DEPENDS 全部可解析：
#   iptables / ip6tables / ip / miniupnpd / nftables 是"虚拟包"（索引里搜不到这个名字），
#   分别由 iptables-nft(1.8.10-r3) / ip6tables-nft(1.8.10-r3) / ip-tiny|ip-full /
#   miniupnpd-nftables(2.3.9-r1) / nftables-json|nftables-nojson(1.1.6-r2) 通过 PROVIDES 提供。
#   它们**真实存在**（在 target 专属索引里），旧版笔记误判为"已移除"。因此：
#     mwan3 的 "+iptables +IPV6:ip6tables"、luci-app-upnp 的 "+miniupnpd" 会自动拉入。
#   ip6tables 是条件依赖：构建配置必须 CONFIG_IPV6=y（ImmortalWrt 默认开启）才会被拉进来，
#   要 IPv6 多拨务必确认这一项，否则 mwan3 的 rtmon_ipv6/ip6tables 规则整段不会启动。
#   miniupnpd-nftables 则必须显式保留，否则 apk 可能在 iptables/nftables 两个变体之间任选。
#
# 【25.12.2 的 FullCone 是内核/fw4 原生能力，不是 turboacc】
#   firewall4 的 Makefile DEPENDS 里就有 +kmod-nft-fullcone；
#   ImmortalWrt 还打了 001-firewall4-add-support-for-fullcone-nat.patch，
#   在 /etc/config/firewall 的 defaults 里新增 fullcone / fullcone6 两个开关（并默认 flow_offloading=1）。
#   所以：不需要 luci-app-turboacc，也不需要手写 nft 规则，见 docs/04-加速-BBR-FullCone-offload.md。
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
# 非常好用的文件管理器 by github sbwml（第三方 feed，25.12.2 官方源没有）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES quickfile luci-app-quickfile luci-i18n-quickfile-zh-cn"
极光主题和配置 by github eamonxg（第三方 feed，25.12.2 官方源无 luci-theme-aurora，需自建 feed 才能用）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"
# 分区扩容 by sirpdboy
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"
# 流量监控 by timsaya（第三方 feed，25.12.2 官方源没有 bandix）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES bandix luci-app-bandix luci-i18n-bandix-zh-cn"
# 新增ssrp apk
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy kmod-nft-socket xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
# 新增passwall apk（注意：25.12.2 官方源里是 luci-app-passwall，没有 luci-app-passwall2）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall luci-i18n-passwall-zh-cn"
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

# MosDNS —— 关键修正（2026-10）：
#   1) 官方源只有 mosdns 5.3.3-r1 内核包，**没有** luci-app-mosdns / luci-i18n-mosdns-zh-cn，
#      原脚本启用后云端编译必然失败，已注释。
#   2) 包里自带的 /etc/mosdns/config.yaml 是 v4 格式（data_providers / fast_forward / servers），
#      而 mosdns 5.3.3 只认 v5 格式（log / include / plugins / api），且用 viper+mapstructure
#      ErrorUnused=true 加载，遇到未知键会直接报 “failed to unmarshal config”。
#      => 装完必须替换成 v5 格式配置，否则服务起不来。完整配置见
#      docs/02-DNS架构-MosDNS分流+ADG去广告.md
CUSTOM_PACKAGES="$CUSTOM_PACKAGES mosdns"

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
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filemanager-zh-cn"
# 网络唤醒
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-wol luci-i18n-wol-zh-cn etherwake"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-timewol-zh-cn"
# 自定义命令
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-commands-zh-cn"

# ============= 红米AX6000 (MT7986) 自定义需求（从 24.10.6 迁移） =============
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-bonding kmod-vrf proto-bonding ip-full"

# OpenClash（24.10 → nftables 专用）
#经考虑在直接在PC上运行收益比较高
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash -dnsmasq dnsmasq-full bash curl ca-bundle ip-full ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base"

# ZeroTier（保留）
# 已在上面“内网穿透”区域启用：zerotier luci-app-zerotier luci-i18n-zerotier-zh-cn

# Syncdial + mwan3（25.12.2 全部在官方源，kmod-macvlan 在 filogic kmods 索引中存在）
# luci-app-syncdial 2.0-r25 / luci-app-mwan3 26.236.50544~cb5d434 / kmod-macvlan 6.12.103-r1
# 注意：syncdial 的 genwancfg 给每个 vwan 写死 mwan3.<if>.family=ipv4，
#       IPv6 多拨必须按 docs/03 手工补 wan6 段（不是 mwan3 不支持 IPv6，是脚本没生成）。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-syncdial kmod-macvlan luci-app-mwan3 luci-i18n-mwan3-zh-cn"
# 如果只准备先验证 MWAN3 包解析，可选下面的单独测试项（非必需）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mwan3 luci-i18n-mwan3-zh-cn"

# MWAN3 的兼容层（必须保留）
# mwan3 2.12.0 的 lib/mwan3/common.sh 里是 IPT4="iptables -t mangle -w" / IPT6="ip6tables -t mangle -w"，
# 全脚本没有 nft 命令 —— 它是 **iptables(mangle) + ipset** 实现，靠 iptables-nft 兼容层落到 nft 表
# （nft list ruleset 里能看到 table ip mangle / table ip6 mangle）。
# 所以：既不能删 iptables-nft/ip6tables-nft，也不要按“纯 nft”思路手工改写 mwan3 规则。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES iptables-nft ip6tables-nft"

# BBR（保留，25.12 建议显式带上 fq 调度器）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-tcp-bbr kmod-sched"

# Turbo ACC + Full Cone
# 结论（有据可查）：
#   1) 25.12.2 官方源没有 luci-app-turboacc / luci-app-turboacc-mtk，它们一直属于
#      lean 等第三方 feed；而且 mufeng05/turboacc 这类能上 25.12 的版本是**内核源码补丁**
#      （add_turboacc.sh 直接改源码树），不是 feed 里的 apk，CUSTOM_PACKAGES 写不进去。
#   2) 25.12 的 FullCone 已由 ImmortalWrt 的 firewall4 补丁原生支持：
#      /etc/config/firewall 的 config defaults 里 option fullcone / option fullcone6，
#      内核侧由 firewall4 依赖的 kmod-nft-fullcone 提供（LuCI 防火墙“常规设置”里的
#      Enable FullCone NAT 复选框，仅当 /sys/module/nft_fullcone 存在时才显示）。
#      => 不需要 turboacc，也不要再手写 nft fullcone 规则。
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-turboacc kmod-nft-fullcone"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-turboacc-mtk"

# 原生软件/硬件流量分载：先于多拨、代理、策略路由测试；不等于启用硬件加速
# kmod-nft-offload 提供 flowtable，kmod-nft-fullcone 提供 fullcone 表达式；
# 后者其实已由 firewall4 依赖自动带入，这里显式写一遍只为让 diff 更清楚。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-offload kmod-nft-fullcone"

# SmartDNS —— 建议注释掉，避免与 MosDNS / OpenClash 的 DNS 控制冲突
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES smartdns luci-app-smartdns luci-i18n-smartdns-zh-cn"

# ===== 轻量局域网管理：IP/MAC 绑定 + 网络唤醒 + 高级重启 =====
# U-Boot Mod 下不要盲目使用高级重启的分区切换功能
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-advanced-reboot luci-i18n-advanced-reboot-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-arpbind luci-i18n-arpbind-zh-cn"
# wol 已在上面“网络唤醒”区域统一启用

# 诊断插件（可选）：不会增加物理带宽，但有助于定位低于 500Mbps 的问题
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-nlbwmon luci-i18n-nlbwmon-zh-cn"
# 如果后续对照证实为缓冲膨胀问题，可考虑 SQM，但不要和 HW Flow Offload 同时启用
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-sqm luci-i18n-sqm-zh-cn sqm-scripts kmod-sched-cake"

# KMS 服务器（vlmcsd）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES vlmcsd luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn luci-lua-runtime"

# ============= AdGuard Home 去广告 / DNS 过滤 =============
# 核心 + LuCI 界面（25.12.2 官方源：adguardhome 0.107.76-r1 / luci-app-adguardhome 26.236.50544~cb5d434）
# 依赖说明：luci-app-adguardhome 的 EXTRA_DEPENDS 要求 adguardhome >= 0.107.73-r3，官方索引正好满足；
# libcares 等动态库由 apk 自动依赖解析，无需手工写死（写死反而在换源时容易失败）。
# 运行形态（已核 adguardhome.init）：procd + ujail  jailed，
#   uci 配置 /etc/config/adguardhome 的 config 段，config_file=/etc/adguardhome/adguardhome.yaml，
#   work_dir=/var/lib/adguardhome，启动命令带 --logfile syslog --no-check-update。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES adguardhome luci-app-adguardhome"

# ============= DNS/网络排障工具（体积小，强烈建议保留） =============
# bind-dig：验证 ADG/MosDNS/dnsmasq 三层解析（docs/02 全部验收命令都用它）
# curl + ca-bundle：下载国内外域名/CN IP 清单、给 mosdns 规则文件更新脚本用
# conntrack：看 NAT/多拨标记，验证 mwan3 与 fullcone 是否真的生效
# ethtool：看 PPPoE/网卡速率与 offload 能力，定位“千兆只跑 500M”
# iputils-ping：mwan3track 的取 ping 顺序是 /usr/bin/ping -4|-6 → ping6 → ping，
#   busybox 的 ping 不保证带 -4/-6，装了它 IPv6 健康检测才是确定的（这才是“mwan3 没开 IPv6”的常见真因之一）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES bind-dig curl ca-bundle conntrack ethtool iputils-ping"

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
# 无线：多 AP 无缝漫游（dawn 与 usteer 二选一，别同时开）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-dawn luci-i18n-dawn-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-usteer"
# 无线：定时开关 Wi-Fi
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-wifischedule luci-i18n-wifischedule-zh-cn"
# 代理类（打开前先确认订阅协议；25.12 官方源内为 luci-app-passwall / luci-app-homeproxy / luci-app-openclash）
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core sing-box hysteria geoview kmod-nft-tproxy kmod-nft-socket luci-app-passwall luci-i18n-passwall-zh-cn"
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
