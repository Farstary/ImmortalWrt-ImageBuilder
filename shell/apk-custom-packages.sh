#!/bin/bash
# ============= ImmortalWrt 25.12.x CUSTOM_PACKAGES 清单 =============
# 基于 24.10.6 插件清单迁移，保留原启用插件，并针对 apk 环境调整。

CUSTOM_PACKAGES="${CUSTOM_PACKAGES:-}"

# ============= 第三方插件 / 首页与主题 =============
# 首页和网络向导（依赖 istore，若集成它则连同 istore 商店）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-quickstart-zh-cn"

# 极光主题和配置
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"

# ============= 代理相关 =============
# OpenClash（25.12 使用 apk 包，包名仍为 luci-app-openclash，但需确保源中有 .apk 格式）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES ruby-psych ruby-pstore kmod-nft-socket"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash -dnsmasq dnsmasq-full bash curl ca-bundle ip-full ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base"

# ============= AdGuard Home 去广告 / DNS 过滤 =============
# 核心 + LuCI 界面（25.12 必须使用 apk 格式）
# 依赖库显式列出，确保 ImageBuilder 构建时能正确解析
CUSTOM_PACKAGES="$CUSTOM_PACKAGES adguardhome luci-app-adguardhome libopenssl libnetwork libcares"
# ⚠️ 注意：dnsmasq 保持默认安装（不要移除），
# 刷机后需在 AdGuard Home 面板中选择“作为 dnsmasq 上游”模式，
# 或将 dnsmasq DNS 端口改为 54/5353，避免 53 端口冲突。

# ============= VPN / 内网穿透 =============
# ZeroTier
CUSTOM_PACKAGES="$CUSTOM_PACKAGES zerotier luci-app-zerotier luci-i18n-zerotier-zh-cn"

# ============= 多拨 / 负载均衡 / 流量分载 =============
# SyncDial + MWAN3 + MACVLAN（注意：部分目标可能缺少独立 kmod-macvlan，若构建报错可临时注释掉 kmod-macvlan 测试）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-syncdial luci-app-mwan3 kmod-macvlan"

# MWAN3 的 iptables/nftables 兼容层
CUSTOM_PACKAGES="$CUSTOM_PACKAGES iptables-nft ip6tables-nft"

# MWAN3 中文包
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"

# 原生软件流量分载（不等于硬件加速）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-offload"

# ============= 轻量局域网管理 =============
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-advanced-reboot luci-i18n-advanced-reboot-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-arpbind luci-i18n-arpbind-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-wol luci-i18n-wol-zh-cn etherwake"

# 带宽监控
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-nlbwmon luci-i18n-nlbwmon-zh-cn"

# KMS 服务器
CUSTOM_PACKAGES="$CUSTOM_PACKAGES vlmcsd luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn"

# ============= BBR（拥塞控制） =============
# BBR 不会直接提升普通 NAT 转发吞吐，按需启用。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-tcp-bbr"

# ============= Turbo ACC（重要：官方 25.12 源中通常不可用） =============
# ImmortalWrt 官方 FAQ 明确指出：23.05 之后因 iptables 被替换为 nftables，基于 iptables 的
# turbo-acc 等插件无法使用。25.12 官方 ImageBuilder 源中一般不存在 luci-app-turboacc，
# 强行加入会导致构建失败，因此这里不直接启用。
# 如果你有第三方适配 firewall4/nftables 的 turboacc 软件源，可以手动取消下面一行注释，
# 但需要自行确保该包及其 kmod 依赖与你的内核 ABI 兼容。
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-turboacc"
#
# 作为流量分载的替代，上面已经保留了 kmod-nft-offload，它在 nftables 环境下是官方支持的原生方案。

# ============= 以下为注释状态，按需启用 =============
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash quickfile luci-app-quickfile luci-i18n-quickfile-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-adguardhome"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openvpn-server luci-i18n-openvpn-server-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-openvpn-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dae-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-daed-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria luci-i18n-passwall-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall2 luci-i18n-passwall2-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-homeproxy-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy kmod-nft-socket xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nikki-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES momo luci-app-momo luci-i18n-momo-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-proto-wireguard"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-tailscale-community luci-i18n-tailscale-community-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-watchdog luci-i18n-watchdog-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-kucat"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mosdns luci-i18n-mosdns-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-turboacc"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-appfilter luci-i18n-appfilter-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-lucky lucky"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-gecoosac gecoosac"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-taskplan luci-i18n-taskplan-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES easytier luci-app-easytier"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES webdav2 luci-app-unishare"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ipsec-vpnd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-bandix luci-i18n-bandix-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dufs-zh-cn"#!/bin/bash
# ============= ImmortalWrt 25.12.x CUSTOM_PACKAGES 清单 =============
# 基于 24.10.6 插件清单迁移，保留原启用插件，并针对 apk 环境调整。

CUSTOM_PACKAGES="${CUSTOM_PACKAGES:-}"

# ============= 第三方插件 / 首页与主题 =============
# 首页和网络向导（依赖 istore，若集成它则连同 istore 商店）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-quickstart-zh-cn"

# 极光主题和配置
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-aurora luci-app-aurora-config luci-i18n-aurora-config-zh-cn"

# 进阶设置（排除 argon-config 避免冲突）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES -luci-app-argon-config -luci-i18n-argon-config-zh-cn luci-app-advancedplus luci-i18n-advancedplus-zh-cn"

# ============= 代理相关 =============
# OpenClash（25.12 使用 apk 包，包名仍为 luci-app-openclash，但需确保源中有 .apk 格式）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash -dnsmasq dnsmasq-full bash curl ca-bundle ip-full ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base"

# ============= VPN / 内网穿透 =============
# ZeroTier
CUSTOM_PACKAGES="$CUSTOM_PACKAGES zerotier luci-app-zerotier luci-i18n-zerotier-zh-cn"

# ============= 多拨 / 负载均衡 / 流量分载 =============
# SyncDial + MWAN3 + MACVLAN（注意：部分目标可能缺少独立 kmod-macvlan，若构建报错可临时注释掉 kmod-macvlan 测试）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-syncdial luci-app-mwan3 kmod-macvlan"

# MWAN3 的 iptables/nftables 兼容层
CUSTOM_PACKAGES="$CUSTOM_PACKAGES iptables-nft ip6tables-nft"

# MWAN3 中文包
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"

# 原生软件流量分载（不等于硬件加速）
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-offload"

# ============= 轻量局域网管理 =============
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-advanced-reboot luci-i18n-advanced-reboot-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-arpbind luci-i18n-arpbind-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-wol luci-i18n-wol-zh-cn etherwake"

# 带宽监控
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-nlbwmon luci-i18n-nlbwmon-zh-cn"

# KMS 服务器
CUSTOM_PACKAGES="$CUSTOM_PACKAGES vlmcsd luci-app-vlmcsd luci-i18n-vlmcsd-zh-cn"

# ============= BBR（拥塞控制） =============
# BBR 不会直接提升普通 NAT 转发吞吐，按需启用。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-tcp-bbr"

# ============= Turbo ACC（重要：官方 25.12 源中通常不可用） =============
# ImmortalWrt 官方 FAQ 明确指出：23.05 之后因 iptables 被替换为 nftables，基于 iptables 的
# turbo-acc 等插件无法使用。25.12 官方 ImageBuilder 源中一般不存在 luci-app-turboacc，
# 强行加入会导致构建失败，因此这里不直接启用。
# 如果你有第三方适配 firewall4/nftables 的 turboacc 软件源，可以手动取消下面一行注释，
# 但需要自行确保该包及其 kmod 依赖与你的内核 ABI 兼容。
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-turboacc"
#
# 作为流量分载的替代，上面已经保留了 kmod-nft-offload，它在 nftables 环境下是官方支持的原生方案。

# ============= 以下为注释状态，按需启用 =============
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-run"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES bash quickfile luci-app-quickfile luci-i18n-quickfile-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-adguardhome"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openvpn-server luci-i18n-openvpn-server-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-openvpn-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dae-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-daed-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria luci-i18n-passwall-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview xray-core sing-box hysteria kmod-nft-socket kmod-nft-tproxy luci-app-passwall2 luci-i18n-passwall2-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-homeproxy-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES kmod-nft-tproxy kmod-nft-socket xray-core naiveproxy luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nikki-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES momo luci-app-momo luci-i18n-momo-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-proto-wireguard"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-tailscale-community luci-i18n-tailscale-community-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-partexp luci-i18n-partexp-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-watchdog luci-i18n-watchdog-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-kucat"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-mosdns luci-i18n-mosdns-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-turboacc"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-appfilter luci-i18n-appfilter-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-lucky lucky"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-gecoosac gecoosac"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-taskplan luci-i18n-taskplan-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES easytier luci-app-easytier"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES webdav2 luci-app-unishare"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ipsec-vpnd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-bandix luci-i18n-bandix-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-rtp2httpd luci-i18n-rtp2httpd-zh-cn"
#CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-dufs-zh-cn"
