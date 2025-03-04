#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
#
# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#

# Add luci-app-tailscale
git clone https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile
#
# Add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# golang 1.24
#rm -rf feeds/packages/lang/golang
#git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# node - prebuilt
rm -rf feeds/packages/lang/node
git clone https://github.com/sbwml/feeds_packages_lang_node-prebuilt feeds/packages/lang/node -b packages-24.10

# default settings
git clone https://github.com/sbwml/default-settings package/new/default-settings -b openwrt-24.10

# luci-app-filemanager
rm -rf feeds/luci/applications/luci-app-filemanager
git clone https://github.com/sbwml/luci-app-filemanager package/new/luci-app-filemanager

# luci-app-airplay2
git clone https://github.com/sbwml/luci-app-airplay2 package/new/airplay2

# luci-app-webdav
git clone https://github.com/sbwml/luci-app-webdav package/new/luci-app-webdav

# ddns - fix boot
sed -i '/boot()/,+2d' feeds/packages/net/ddns-scripts/files/etc/init.d/ddns

# lrzsz - 0.12.20
rm -rf feeds/packages/utils/lrzsz
git clone https://github.com/sbwml/packages_utils_lrzsz package/new/lrzsz

# samba4 - bump version
rm -rf feeds/packages/net/samba4
git clone https://github.com/sbwml/feeds_packages_net_samba4 feeds/packages/net/samba4
# liburing - 2.7 (samba-4.21.0)
rm -rf feeds/packages/libs/liburing
git clone https://github.com/sbwml/feeds_packages_libs_liburing feeds/packages/libs/liburing
# enable multi-channel
sed -i '/workgroup/a \\n\t## enable multi-channel' feeds/packages/net/samba4/files/smb.conf.template
sed -i '/enable multi-channel/a \\tserver multi channel support = yes' feeds/packages/net/samba4/files/smb.conf.template
# default config
sed -i 's/#aio read size = 0/aio read size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#aio write size = 0/aio write size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/invalid users = root/#invalid users = root/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' feeds/luci/applications/luci-app-samba4/htdocs/luci-static/resources/view/samba4.js
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/smb.conf.template

# unblockneteasemusic
rm -rf feeds/packages/luci-app-unblockneteasemusic
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/new/luci-app-unblockneteasemusic
sed -i 's/解除网易云音乐播放限制/网易云音乐解锁/g' package/new/luci-app-unblockneteasemusic/root/usr/share/luci/menu.d/luci-app-unblockneteasemusic.json

# Theme
git clone --depth 1 https://github.com/sbwml/luci-theme-argon package/new/luci-theme-argon

# tcp-brutal
#git clone https://github.com/sbwml/package_kernel_tcp-brutal package/kernel/tcp-brutal

#Add dash to mihomo
mkdir -p files/etc/nikki/run/ui

# Download and extract zashboard
curl -Lso zashboard.zip https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip
unzip zashboard.zip
rm -rf files/etc/nikki/run/ui/metacubexd
mv dist files/etc/nikki/run/ui/zashboard
rm zashboard.zip

# Download and extract Yacd-meta-gh-pages
curl -Lso Yacd-meta-gh-pages.zip https://github.com/MetaCubeX/yacd/archive/gh-pages.zip
unzip Yacd-meta-gh-pages.zip
mv Yacd-meta-gh-pages files/etc/nikki/run/ui/yacd
rm Yacd-meta-gh-pages.zip

# Download and extract Razord-meta-gh-pages
curl -Lso Razord-meta-gh-pages.zip https://github.com/MetaCubeX/Razord-meta/archive/refs/heads/gh-pages.zip
unzip Razord-meta-gh-pages.zip
mv Razord-meta-gh-pages files/etc/nikki/run/ui/dashboard
rm Razord-meta-gh-pages.zip
#
# ------------------------------- Other ends -------------------------------


# ------------------------------- Other ends -------------------------------

