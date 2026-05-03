#!/usr/bin/env bash

########################################
# SOURCE SETUP
########################################

echo "==> Resetting manifests and toolchain..."
rm -rf .repo/local_manifests prebuilts/clang/host/linux-x86

echo "==> Initializing repo..."
repo init -u https://github.com/AndroidOne-Experience/manifest.git -b 15 --depth=1 --git-lfs 
git clone https://github.com/andrey167/android_local_manifests --depth=1 -b aosp .repo/local_manifests

########################################
# SYNC SOURCE
########################################

echo "==> Syncing source..."
repo sync -c -j32 --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh


########################################
# BUILD SETUP
########################################

echo "==> Preparing environment..."
. build/envsetup.sh

export BUILD_USERNAME=andrey167
export BUILD_HOSTNAME=crave
export TZ=Asia/Jakarta
export KBUILD_USERNAME="$BUILD_USERNAME"
export KBUILD_HOSTNAME="$BUILD_HOSTNAME"

git clone https://github.com/Evolution-X/vendor_evolution-priv_keys-template vendor/evolution-priv/keys
cd vendor/evolution-priv/keys
./keys.sh
cd -

grep -q "vendor/evolution-priv/keys/keys.mk" device/xiaomi/platina/BoardConfig.mk || sed -i '$ a -include vendor/evolution-priv/keys/keys.mk' device/xiaomi/platina/aosp_platina.mk
#sed -i 's/PRODUCT_CERTIFICATE_OVERRIDES/PRODUCT_PACKAGE_NAME_OVERRIDES/g' vendor/evolution-priv/keys/keys.mk
tail -5 device/xiaomi/platina/aosp_platina.mk

echo "==> Lunching target..."
lunch aosp_platina-bp1a-user

echo "==> Cleaning previous build outputs..."
m installclean


echo "==> All tasks completed successfully!"
