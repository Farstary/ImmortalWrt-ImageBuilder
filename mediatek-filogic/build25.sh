#!/bin/bash
source shell/apk-custom-packages.sh
#echo "✅ 你选择了第三方软件包：$CUSTOM_PACKAGES"
if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # ============= 同步第三方插件库==============
  # 同步第三方软件仓库run/apk
  echo "🔄 正在同步第三方软件仓库 Cloning apk file repo..."
  git clone --depth=1 https://github.com/wukongdaily/apk.git /tmp/store-apk-repo

  # 拷贝 run/arm64 下所有 run 文件和apk文件 到 extra-packages 目录
  mkdir -p /home/build/immortalwrt/extra-packages
  cp -r /tmp/store-apk-repo/run/arm64-a53/* /home/build/immortalwrt/extra-packages/

  echo "✅ Run files copied to extra-packages:"
  # 解压并拷贝apk到packages目录
  sh shell/apk-prepare-packages.sh
  ls -lah /home/build/immortalwrt/packages/
fi


# ============================================================
# FastNet 网络测速 - 独立 APK 集成
# 无需 iStore 软件中心
# ============================================================

if [[ " $CUSTOM_PACKAGES " == *" fastnet "* ]]; then

    echo "正在准备 FastNet APK..."

    FASTNET_REPO="https://istore.istoreos.com/repo-apk"
    FASTNET_DIR="/home/build/immortalwrt/packages"

    mkdir -p "$FASTNET_DIR"

    # 固定版本，避免上游更新导致不可重复构建
    FASTNET_APKS=(
        "aarch64_generic/nas/fastnet-0.7.8-r1.apk"              # 主程序已更新
        "all/nas_luci/luci-app-fastnet-0.7.8-r5.apk"           # LuCI 界面已更新
        "all/nas_luci/luci-i18n-fastnet-zh-cn-26.299.06522~751755a.apk"  # 中文包已更新
        "aarch64_generic/nas/linkease-app-entry-3.0.23-r1.apk"  # 建议核实或移除，仓库中可能已变更
        "all/nas_luci/luci-lib-linkeaseauth-1.2.1-r1.apk"
    )

    for package in "${FASTNET_APKS[@]}"; do

        filename="${package##*/}"
        url="$FASTNET_REPO/$package"
        target="$FASTNET_DIR/$filename"

        echo "下载 FastNet 软件包: $filename"

        # 失败立即终止，禁止缺包继续构建
        if ! curl -fL \
            --retry 3 \
            --connect-timeout 15 \
            --max-time 180 \
            -o "$target" \
            "$url"; then

            echo "错误: FastNet 软件包下载失败: $filename"
            exit 1
        fi

        # 检查文件存在且非空
        if [ ! -s "$target" ]; then
            echo "错误: FastNet APK 文件为空: $filename"
            exit 1
        fi

    done

    echo "FastNet APK 下载完成:"
    ls -lh "$FASTNET_DIR"/*fastnet*.apk
    ls -lh "$FASTNET_DIR"/*linkease*.apk

else
    echo "未选择 FastNet，跳过 APK 下载"
fi

# ============================================================
# FastNet APK 集成结束
# ============================================================


# yml 传入的路由器型号 PROFILE
echo "Building for profile: $PROFILE"

echo "Include Docker: $INCLUDE_DOCKER"
echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# 创建pppoe配置文件 yml传入pppoe变量————>pppoe-settings文件
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF


# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting build process..."


# 定义所需安装的包列表 下列插件你都可以自行删减
PACKAGES=""
PACKAGES="$PACKAGES curl luci luci-i18n-base-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-theme-argon"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
# 文件管理器
PACKAGES="$PACKAGES luci-i18n-filemanager-zh-cn"


# 第三方软件包 合并
# ======== shell/apk-custom-packages.sh =======
PACKAGES="$PACKAGES $CUSTOM_PACKAGES"


# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi

# 若构建openclash 则添加内核
if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    # Download clash_meta
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
    wget -qO- $META_URL | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    # Download GeoIP and GeoSite
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O files/etc/openclash/GeoIP.dat
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O files/etc/openclash/GeoSite.dat
    # Download latest openclash Client
    URL=$(curl -s https://api.github.com/repos/vernesong/OpenClash/releases/latest \
      | grep "browser_download_url.*apk" \
      | head -n1 \
      | cut -d '"' -f 4)
    echo "OpenClash latest apk: $URL"
    wget "$URL" -P /home/build/immortalwrt/packages/
else
    echo "⚪️ 未选择 luci-app-openclash"
fi


# ============================================================
# FastNet: ImageBuilder APK 兼容架构配置
# 主架构: aarch64_cortex-a53
# 附加架构: aarch64_generic
# ============================================================

if [[ " $PACKAGES " == *" fastnet "* ]]; then

    echo "🔧 正在配置 FastNet APK 兼容架构..."

    IB_MAKEFILE="/home/build/immortalwrt/Makefile"

    # 确认当前 ImageBuilder Makefile 存在
    if [ ! -f "$IB_MAKEFILE" ]; then
        echo "❌ 找不到 ImageBuilder Makefile"
        exit 1
    fi

    # 检查应修改的架构参数位置
    ARCH_PATTERN='--arch $(ARCH_PACKAGES)'
    MATCH_COUNT=$(grep -Fc -- "$ARCH_PATTERN" "$IB_MAKEFILE")

    if [ "$MATCH_COUNT" -ne 2 ]; then
        echo "❌ ImageBuilder 架构参数位置与预期不同: $MATCH_COUNT"
        echo "请检查当前 ImageBuilder 版本"
        exit 1
    fi

    # 追加 aarch64_generic 为兼容架构
    # 保留原始 Cortex-A53 主架构
    sed -i \
        's/--arch $(ARCH_PACKAGES)/--arch $(ARCH_PACKAGES) --arch aarch64_generic/g' \
        "$IB_MAKEFILE" || exit 1

    echo "✅ APK 兼容架构配置完成"

    grep -nF \
        -- '--arch $(ARCH_PACKAGES) --arch aarch64_generic' \
        "$IB_MAKEFILE" || exit 1

else
    echo "⚪️ 未选择 FastNet，保持默认架构配置"
fi

# ============================================================


# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files"

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
