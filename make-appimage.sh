#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q partitionmanager | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/partitionmanager.svg
export DESKTOP=/usr/share/applications/org.kde.partitionmanager.desktop
export STARTUPWMCLASS=org.kde.partitionmanager
export DEPLOY_QT=1
export QT_DIR=qt6

# Deploy dependencies
quick-sharun /usr/bin/partitionmanager /usr/share/config.kcfg 

# Additional changes can be done in between here
dst=./AppDir/share/polkit-1/actions
mkdir -p "$dst"
cp -v /usr/share/polkit-1/actions/org.kde.kpmcore.externalcommand.policy "$dst"
sed -i -e 's|/usr/sbin|/usr/local/sbin|g' "$dst"/org.kde.kpmcore.externalcommand.policy

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
